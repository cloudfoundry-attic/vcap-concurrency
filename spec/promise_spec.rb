require "spec_helper"

describe VCAP::Concurrency::Promise do
  describe "#deliver " do
    it "should deliver the supplied result to callers of resolve" do
      promise = VCAP::Concurrency::Promise.new
      promise.deliver(:done)
      promise.resolve.should == :done
    end

    it "should raise an error if called more than once" do
      promise = VCAP::Concurrency::Promise.new
      promise.deliver
      expect do
        promise.deliver
      end.to raise_error(/completed once/)
    end

    it "should wake up all threads that are resolving it" do
      promise = VCAP::Concurrency::Promise.new
      lock = Mutex.new
      cond = ConditionVariable.new
      waiting = 0
      threads = []
      5.times do |ii|
        threads << Thread.new do
          lock.synchronize do
            waiting += 1
            cond.signal
          end
          promise.resolve
        end
      end

      done = false
      while !done
        lock.synchronize do
          if waiting == threads.length
            done = true
          else
            cond.wait(lock)
          end
        end
      end

      promise.deliver

      # join returns nil if timeout occurred and the thread hadn't finished
      threads.each { |t| t.join(1).should == t }
    end
  end

  describe "#fail" do
    it "should deliver the supplied exception to callers of resolve" do
      promise = VCAP::Concurrency::Promise.new
      error_text = "test error"
      promise.fail(RuntimeError.new(error_text))
      expect do
        promise.resolve
      end.to raise_error(/#{error_text}/)
    end

    it "should raise an error if called more than once" do
      promise = VCAP::Concurrency::Promise.new
      e = RuntimeError.new("test")
      promise.fail(e)
      expect do
        promise.fail(e)
      end.to raise_error(/completed once/)
    end
  end
end
