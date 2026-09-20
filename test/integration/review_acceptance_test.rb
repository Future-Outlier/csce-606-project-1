class SaveAcceptanceTest < Minitest::Test
  EXECUTABLE = File.expand_path('../../bin/tarot', __dir__)
  FAKE_RUNNER = File.expand_path('../support/fake_qwen_runner.rb', __dir__)

  def setup
    @directory = Dir.mktmpdir('tarot-save-acceptance-test')
    @path = File.join(@directory, 'readings.json')
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def test_rejects_review_at_the_main_menu_and_continues
    output = run_cli("review\nhelp\nexit\n")
    assert_includes output, 'Nothing to review.'
    assert_includes output, 'Usage: tarot [command]'
  end
end
