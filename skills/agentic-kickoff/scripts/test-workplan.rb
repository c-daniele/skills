# Exercise the installed reader and create-only recovery against real local boards.
require 'cgi'
require 'digest'
require 'fileutils'
require 'json'
require 'open3'
require 'tmpdir'
require 'time'
require 'yaml'

SCRIPTS = File.expand_path(__dir__)
GENERATOR = 'scripts/workplan.rb'
MASTER = '.backlog/masterplan/MASTERPLAN.md'
VIEW = 'WORKPLAN.md'

def run(*args, ok: true)
  output, status = Open3.capture2e({ 'BACKLOG_CWD' => Dir.pwd }, *args)
  raise "Unexpected exit #{status.exitstatus}: #{args.inspect}\n#{output}" unless status.success? == ok
  output
end

def assert(condition, message)
  raise message unless condition
end

def record(*args)
  run('backlog', *args)
end

def tasks
  JSON.parse(record('task', 'list', '--json')).fetch('tasks')
end

def check_links(path)
  File.read(path).scan(/\]\(([^)]+)\)/).flatten.each do |target|
    assert(File.exist?(File.expand_path(CGI.unescape(target), File.dirname(path))), "Broken link in #{path}: #{target}")
  end
end

def refresh(expected_path = VIEW)
  run('ruby', GENERATOR, '--write')
  run('ruby', GENERATOR, '--check')
  check_links(expected_path)
  File.read(expected_path)
end

def row(page, title, state, *facts)
  line = page.lines.find { |l| l.start_with?("| #{title} (") }
  assert(line && ([state] + facts).all? { |s| line.include?(s) }, "Unexpected row for #{title}: #{line}")
end

unless system('backlog', '--version', out: File::NULL, err: File::NULL)
  puts 'SKIP: backlog not installed; workplan board and recovery integration not run.'
  exit
end

Dir.mktmpdir('kickoff-plans-') do |tmp|
  Dir.chdir(tmp) do
    record('init', 'Loan Desk', '--defaults', '--integration-mode', 'none', '--backlog-dir', '.backlog', '--config-location', 'folder', '--no-git')
    assert(record('config', 'get', 'projectName').strip == 'Loan Desk', 'Wrong board')
    kickoff = '.backlog/brainstorming/2026-01-01.Kickoff'
    staged = File.join(kickoff, 'approved')
    preview = 'scratch'
    run('bash', File.join(SCRIPTS, 'test-render.sh'), '--fixture', preview)
    files = ['MANIFESTO.md', MASTER, 'AGENTS.md', GENERATOR, VIEW]
    manifest = files.map do |f|
      path = File.join(staged, f)
      FileUtils.mkdir_p(File.dirname(path))
      if f == VIEW # Render the proposal against the target board, not the staging tree.
        File.write(path, run('ruby', File.join(staged, GENERATOR), '--stdout'))
      else
        FileUtils.cp(File.join(preview, f), path)
      end
      [f, Digest::SHA256.file(path).hexdigest]
    end.to_h
    brief = File.join(kickoff, 'KICKOFF-BRIEF.md')
    File.write(brief, "Status: writing\n#{JSON.generate(manifest)}\n")
    install = ->(f, hash, ok = true) { run('bash', File.join(SCRIPTS, 'install-approved.sh'), File.join(staged, f), f, hash, ok: ok) }

    # Interrupt after the first two destinations. Detect a concurrent edit on
    # resume, then simulate its author restoring the approved text explicitly.
    files.first(2).each { |f| install.call(f, manifest.fetch(f)) }
    approved_master = File.binread(MASTER)
    File.open(MASTER, 'a') { |f| f.puts 'User correction pending review.' }
    install.call(MASTER, manifest.fetch(MASTER), false)
    assert(File.read(MASTER).include?('User correction'), 'Lost user edit on recovery')
    File.binwrite(MASTER, approved_master)
    resumed = JSON.parse(File.readlines(brief).last)
    resumed.each { |f, hash| install.call(f, hash) }
    inodes = files.map { |f| File.stat(f).ino }
    resumed.each { |f, hash| install.call(f, hash) }
    assert(inodes == files.map { |f| File.stat(f).ino }, 'Repeated install rewrote a destination')
    files.grep(/\.md$/).each { |f| check_links(f) }
    files.each { |f| assert(!File.read(f).match?(/\{\{|<!-- (BEGIN|END):|guidance:|value-[A-Z_]+/), "Unrendered token in #{f}") }
    run('ruby', GENERATOR, '--check')
    assert(tasks.empty? && Dir['.backlog/drafts/*.md'].empty?, 'Documents created work')
    assert(File.read(VIEW).include?('No executable work has been defined yet'), 'Missing zero-task explanation')
    # A documents-only checkout need not retain empty record directories.
    FileUtils.mv('.backlog/tasks', 'saved-empty-tasks')
    run('ruby', GENERATOR, '--check')
    FileUtils.mv('saved-empty-tasks', '.backlog/tasks')
    FileUtils.remove_entry(kickoff)

    # Interrupt Phase 2 after CLI creation but before the returned ID is saved.
    # Follow the attempt journal: compare time and exact approved fields and
    # adopt the single existing match; the second pass must use its recorded ID.
    title = 'Try the return form with a librarian'
    ac = 'A librarian can record a sample return.'
    desc = "Try a return at the lending desk.\nEffort: 2–4 hours"
    journal = '.backlog/brainstorming/2026-01-01.Decomposition/TASK-TREE.md'
    FileUtils.mkdir_p(File.dirname(journal))
    start = Time.now.utc.strftime('%Y-%m-%dT%H:%M:00Z') # older CLI records minute precision
    File.write(journal, "Approved; attempted #{start}: #{title}\n#{desc}\n#{ac}\n")
    record('task', 'create', title, '--status', 'In Progress', '--type', 'task', '--priority', 'High', '--ac', ac, '-d', desc, '--plain')
    candidates = tasks.select { |t| t['title'] == title }
    assert(candidates.size == 1, 'Ambiguous or missing attempt')
    id = candidates.first.fetch('id')
    task = JSON.parse(record('task', 'view', id, '--json')).fetch('task')
    assert(Time.parse(task.fetch('createdAt')) >= Time.parse(start) && task['description'] == desc &&
      task.values_at('status', 'type', 'priority', 'parentTaskId', 'labels', 'dependencies', 'references') ==
      ['In Progress', 'task', 'high', nil, [], [], []] && task.fetch('acceptanceCriteria').map { |a| a['text'] } == [ac], 'Not an exact attempt match')
    File.open(journal, 'a') { |f| f.puts id }
    assert(tasks.map { |t| t['id'] } == [File.readlines(journal).last.strip], 'Duplicate task on resume')
    run('ruby', GENERATOR, '--check', ok: false)
    record('task', 'create', 'Prepare a paper sign', '--status', 'Done', '--ac', 'The desk has a sign.', '--plain')
    assert(refresh.include?('No checks have a reported result here yet.'), 'Status was presented as verification')
    record('task', 'edit', id, '--notes', 'Verified: A librarian found the sample loan by item number.', '--plain')
    record('task', 'create', 'Publish the return instructions', '--status', 'To Do', '--depends-on', id, '--plain')
    record('task', 'create', 'Check the desk signs', '--status', 'To Do', '-d', 'Effort: 1 hour', '--plain')
    record('draft', 'create', 'Send return reminders', '-d', 'Waiting for: The head librarian must choose when to send the reminder.')
    record('task', 'create', 'Offer after-hours returns', '--status', 'To Do', '--labels', 'proposal', '--plain')
    page = refresh
    row(page, title, 'In Progress', '2–4 hours')
    row(page, 'Publish the return instructions', 'Waiting (To Do)', "Wait for: #{title}", 'Not estimated yet')
    row(page, 'Send return reminders', 'Proposed (Draft)', 'head librarian')
    row(page, 'Offer after-hours returns', 'Proposed (To Do)', 'approval')
    row(page, 'Check the desk signs', 'Ready to start (To Do)', '1 hour')
    assert(page.include?("**Next action:** #{title}") && page.lines.grep(/In parallel/).first.include?('Check the desk signs'), 'Missing next/parallel action')
    assert(page.include?('A librarian found the sample loan by item number.'), 'Missing observed result')

    record('task', 'edit', id, '--status', 'Done', '--check-ac', '1', '--final-summary', 'Verified: A librarian recorded a sample return without help.', '--plain')
    run('ruby', GENERATOR, '--check', ok: false)
    assert(File.read(VIEW) == page, 'Freshness check wrote the file')
    page = refresh
    row(page, 'Publish the return instructions', 'Ready to start (To Do)', "After #{title}")
    row(page, 'Offer after-hours returns', 'Proposed (To Do)')
    assert(page.include?('A librarian recorded a sample return without help.'), 'Closure evidence stale')
    assert(File.binread(MASTER) == approved_master, 'A record update changed project direction')
    File.open(VIEW, 'a') { |f| f.puts 'User question: which desk?' }
    run('ruby', GENERATOR, '--write', ok: false)
    assert(File.read(VIEW).end_with?("User question: which desk?\n"), 'Lost user edit on refresh')

    # Existing project with root config, custom ID prefix, paths and vocabulary.
    FileUtils.mkdir_p('existing')
    Dir.chdir('existing') do
      record('init', 'Loan Desk', '--defaults', '--integration-mode', 'none', '--backlog-dir', 'work items', '--config-location', 'root', '--task-prefix', 'loan', '--no-git')
      config_file = 'backlog.config.yml'
      config = YAML.safe_load(File.read(config_file)).merge('statuses' => %w[Intake Authorized Trial Delivered], 'default_status' => 'Intake')
      File.write(config_file, YAML.dump(config))
      settings = { project: 'Loan Desk', intro: 'Librarians use Loan Desk to lend equipment.', config: config_file,
                   view: 'docs/today.md', masterplan: 'direction and scope.md', statuses: { Intake: 'proposal', Authorized: 'ready', Trial: 'active', Delivered: 'done' } }
      File.write(settings[:masterplan], "# Existing direction\nKeep this text.\n")
      FileUtils.mkdir_p(%w[scripts docs])
      template = File.read(File.join(SCRIPTS, '../assets/templates/workplan.rb.tmpl'))
      File.write(GENERATOR, template.sub('{{WORKPLAN_SETTINGS}}') { JSON.generate(settings) })
      record('task', 'create', 'Extend the trial', '--status', 'Intake', '-d', 'Waiting for: The desk manager must name a second location.', '--plain')
      record('task', 'create', 'Run a paid trial', '--status', 'Authorized', '-d', 'Waiting for: The service owner must approve the spending limit before the first paid test.', '--plain')
      File.write(settings[:view], run('ruby', GENERATOR, '--stdout'))
      page = refresh(settings[:view])
      row(page, 'Extend the trial', 'Proposed (Intake)', 'desk manager')
      row(page, 'Run a paid trial', 'Waiting (Authorized)', 'service owner')
      assert(page.include?('../work%20items/tasks/loan-') && !File.exist?('.backlog'), 'Invented default board path or ID')
      record('task', 'create', 'Prepare the desk', '--status', 'Trial', '--plain')
      parent = tasks.find { |t| t['title'] == 'Prepare the desk' }.fetch('id')
      %w[labels signs].each { |item| record('task', 'create', "Print the #{item}", '-p', parent, '--status', 'Authorized', '--plain') }
      parallel = refresh(settings[:view]).lines.find { |l| l.include?('In parallel') }
      assert(parallel && parallel.include?('Print the labels') && parallel.include?('Print the signs'), 'Independent slices of an epic should be visible')
    end
  end
end
puts 'OK: real-board zero-task kickoff, staged recovery and task reconciliation, progress/evidence/effort, blocked proposals, stale and edited views, custom board and nested view.'
