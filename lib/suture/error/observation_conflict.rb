module Suture::Error
  class ObservationConflict < StandardError
    def initialize(name, args_inspect, new_result, old_observation)
      @name = name
      @args_inspect = args_inspect
      @new_result = new_result
      @old_id = old_observation.id
      @old_result = old_observation.result
    end

    def message
      <<-MSG.gsub(/^ {8}/, "")
        At seam #{@name.inspect}, we just recorded a duplicate call, but the same arguments
        resulted in a different output. Read on for details:

        Arguments: ```
          #{@args_inspect}
        ```
        Previously-observed return value: ```
          #{@old_result.value.inspect}
        ```
        Newly-observed return value: ```
          #{@new_result.value.inspect}
        ```

        That's not good! Here are a few ideas of what may have happened:

        1. The old code path may have a side effect that results in different
           return values. If it's possible, to create the suture at a point after
           this side effect. Otherwise, read on.

        2. Either environmental differents (e.g. system time resulting in a
           different timestamp) or side effects (e.g. saving to a database
           resulting in a different GUID value) mean that Suture is detecting two
           different results for the same inputs. This can be worked around by
           providing a custom comparator to Suture. For more info, see the README:

             https://github.com/testdouble/suture#creating-a-custom-comparator

        3. If neither of the above are true, it's possible that the old code path
           was changed while still in the early stage of recording characterization
           calls (presumably by mistake). If such a change may have occurred in
           error, check your git history. Otherwise, perhaps you `record_calls` is
           accidentally still enabled and should be turned off for this seam
           (either with SUTURE_RECORD_CALLS=false or :record_calls => false).

        4. If, after exhausting the possibilities above, you're pretty sure the
           recorded result is in error, you can delete it from Suture's database
           with:

             Suture.delete!(#{@old_id})
      MSG
    end
  end
end
