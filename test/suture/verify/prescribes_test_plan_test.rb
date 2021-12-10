require "suture/reset"
require "suture/verify/prescribes_test_plan"

class PrescribesTestPlanTest < UnitTest
  def setup
    super
    @subject = Suture::PrescribesTestPlan.new
  end

  def teardown
    super
    ENV.delete_if { |(k, _v)| k.start_with?("SUTURE_") }
    Suture.reset!
  end

  def test_defaults
    result = @subject.prescribe(:foo)

    assert_equal :foo, result.name
    assert_equal false, result.fail_fast
    assert_nil result.call_limit
    assert_nil result.time_limit
    assert_nil result.error_message_limit
    assert_equal "db/suture.sqlite3", result.adapter_options[:database_path]
    assert_kind_of Suture::Comparator, result.comparator
    assert_includes 0..99999, result.random_seed
    assert_nil result.verify_only
    assert_equal [], result.expected_error_types
  end

  def test_global_overrides
    Suture.config(
      :adapter_options => {
        :adapter => "sqlite",
        :database_path => "other.db",
      },
      :comparator => :lolcompare,
      :random_seed => nil
    )

    result = @subject.prescribe(:foo)

    assert_equal "other.db", result.adapter_options[:database_path]
    assert_equal :lolcompare, result.comparator
    assert_nil result.random_seed
  end

  def test_options
    some_subject = lambda {}
    some_after_subject = lambda {}
    some_on_subject_error = lambda {}

    result = @subject.prescribe(:foo,
      :adapter_options => {
        :adapter => "sqlite",
        :database_path => "db",
      },
      :subject => some_subject,
      :fail_fast => true,
      :call_limit => 11,
      :time_limit => 99,
      :error_message_limit => 83,
      :comparator => :lol_compare,
      :verify_only => 42,
      :random_seed => 1337,
      :after_subject => some_after_subject,
      :on_subject_error => some_on_subject_error,
      :expected_error_types => [ZeroDivisionError])

    assert_equal :foo, result.name
    assert_equal some_subject, result.subject
    assert_equal true, result.fail_fast
    assert_equal 11, result.call_limit
    assert_equal 99, result.time_limit
    assert_equal 83, result.error_message_limit
    assert_equal "db", result.adapter_options[:database_path]
    assert_equal :lol_compare, result.comparator
    assert_equal 42, result.verify_only
    assert_equal 1337, result.random_seed
    assert_equal some_after_subject, result.after_subject
    assert_equal some_on_subject_error, result.on_subject_error
    assert_equal [ZeroDivisionError], result.expected_error_types
  end

  def test_env_vars
    ENV["SUTURE_NAME"] = "bad name"
    ENV["SUTURE_SUBJECT"] = "sub"
    ENV["SUTURE_ADAPTER"] = "sqlite"
    ENV["SUTURE_ADAPTER_DATABASE_PATH"] = "d"
    ENV["SUTURE_COMPARATOR"] = "e"
    ENV["SUTURE_FAIL_FAST"] = "true"
    ENV["SUTURE_CALL_LIMIT"] = "91"
    ENV["SUTURE_TIME_LIMIT"] = "20"
    ENV["SUTURE_ERROR_MESSAGE_LIMIT"] = "999"
    ENV["SUTURE_VERIFY_ONLY"] = "42"
    ENV["SUTURE_RANDOM_SEED"] = "9922"
    ENV["SUTURE_AFTER_SUBJECT"] = "lol"
    ENV["SUTURE_ON_SUBJECT_ERROR"] = "lol"
    ENV["SUTURE_EXPECTED_ERROR_TYPES"] = "nai"

    result = @subject.prescribe(:a_name)

    assert_equal "d", result.adapter_options[:database_path]
    assert_equal true, result.fail_fast
    assert_equal 91, result.call_limit
    assert_equal 20, result.time_limit
    assert_equal 42, result.verify_only
    assert_equal 999, result.error_message_limit
    assert_equal 9922, result.random_seed
    # options that can't be set with ENV vars:
    assert_equal :a_name, result.name
    assert_nil result.subject
    assert_kind_of Suture::Comparator, result.comparator
    assert_nil result.after_subject
    assert_nil result.on_subject_error
    assert_equal [], result.expected_error_types
  end

  def test_special_env_vars
    ENV["SUTURE_RANDOM_SEED"] = "nil"

    result = @subject.prescribe(:a_name)

    assert_nil result.random_seed
  end
end
