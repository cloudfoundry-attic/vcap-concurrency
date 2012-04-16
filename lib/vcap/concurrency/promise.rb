require "thread"

module VCAP
  module Concurrency
  end
end

# A promise represents the intent to complete a unit of work at some point
# in the future.
class VCAP::Concurrency::Promise
  def initialize
    @lock   = Mutex.new
    @cond   = ConditionVariable.new
    @done   = false
    @result = nil
    @error  = nil
  end

  # Fulfills the promise successfully. Anyone blocking on the result will be
  # notified immediately.
  #
  # @param  [Object]  result   The result of the associated computation.
  #
  # @return [nil]
  def deliver(result = nil)
    @lock.synchronize do
      assert_not_done

      @result = result
      @done = true

      @cond.broadcast
    end

    nil
  end

  # Fulfills the promise unsuccessfully. Anyone blocking on the result will
  # be notified immediately.
  #
  # NB: The supplied exception will be re raised in the caller of #resolve().
  #
  # @param  [Exception]  The error that occurred while fulfilling the promise.
  #
  # @return [nil]
  def fail(exception)
    @lock.synchronize do
      assert_not_done

      @error = exception
      @done = true

      @cond.broadcast
    end

    nil
  end

  # Waits for the promise to be fulfilled. Blocks the calling thread if the
  # promise has not been fulfilled, otherwise it returns immediately.
  #
  # NB: If the promise failed to be fulfilled, the error that occurred while
  #     fulfilling it will be raised here.
  #
  # @return [Object]  The result of the associated computation.
  def resolve
    @lock.synchronize do
      @cond.wait(@lock) unless @done

      if @error
        raise @error
      else
        @result
      end
    end
  end

  private

  def assert_not_done
    raise "A promise may only be completed once." if @done
  end
end
