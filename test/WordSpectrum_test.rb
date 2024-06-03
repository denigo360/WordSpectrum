require 'test_helper'

class TextAnalyzerTest < Minitest::Test
  def setup
    @analyzer = TextAnalyzer::Analyzer.new
    @test_folder = 'test/data'
    FileUtils.mkdir_p(@test_folder) unless Dir.exist?(@test_folder)
  end

  def teardown
    FileUtils.rm_rf(@test_folder) if Dir.exist?(@test_folder)
  end

  def test_analyze_empty_folder
    assert_empty(@analyzer.analyze("#{@test_folder}"))
  end

  def test_analyze_single_file_without_stop_words
    create_test_file('file1.txt', "Привет мир! Это тестовый файл.")
    expected_counts = {
      'привет' => 1,
      'мир' => 1,
      'это' => 1,
      'тестовый' => 1,
      'файл' => 1
    }
    assert_equal expected_counts, @analyzer.analyze("#{@test_folder}")
  end

  def test_analyze_multiple_files_with_stop_words
    create_test_file('file1.txt', "Привет мир! Это тестовый файл.")
    create_test_file('file2.txt', "Мир, это прекрасный мир!")
    @analyzer = TextAnalyzer::Analyzer.new(['это'])
    expected_counts = {
      'привет' => 1,
      'мир' => 2,
      'тестовый' => 1,
      'файл' => 1,
      'прекрасный' => 1
    }
    assert_equal expected_counts, @analyzer.analyze("#{@test_folder}")
  end

  def test_analyze_single_file_with_lemmatization
    create_test_file('file1.txt', "Я люблю читать книги. Книги - это прекрасно.")
    @analyzer = TextAnalyzer::Analyzer.new([], true)
    expected_counts = {
      'я' => 1,
      'любить' => 1,
      'читать' => 1,
      'книга' => 2,
      'это' => 1,
      'прекрасно' => 1
    }
    assert_equal expected_counts, @analyzer.analyze("#{@test_folder}")
  end

  private

  def create_test_file(file_name, content)
    File.open("#{@test_folder}/#{file_name}", 'w') do |file|
      file.write(content)
    end
  end
end