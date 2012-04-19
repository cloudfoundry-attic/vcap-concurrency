require "spec_helper"

describe VCAP::Concurrency::AtomicVar do
  describe "#value" do
    it "should return the current value" do
      iv = 5
      av = VCAP::Concurrency::AtomicVar.new(iv)
      av.value.should == iv
    end
  end

  describe "#value=" do
    it "should allow the current value to be changed" do
      av = VCAP::Concurrency::AtomicVar.new(1)
      nv = 2
      av.value = nv
      av.value.should == nv
    end
  end

  describe "#mutate" do
    it "should update the value to the result of the supplied block" do
      iv = 2
      av = VCAP::Concurrency::AtomicVar.new(iv)
      av.mutate { |v| v * v }
      av.value.should == (iv * iv)
    end
  end

  describe "#wait_value_changed" do
    it "should return immediately if the current value differs from the supplied value" do
      iv = 1
      av = VCAP::Concurrency::AtomicVar.new(iv)
      av.wait_value_changed(2).should == iv
    end

    it "should block if the current value is the same" do
      barrier = VCAP::Concurrency::AtomicVar.new(0)

      # We're using the atomic var as a form of synchronization here. Each
      # thread will count half the values up to 6, waiting for the other
      # thread before proceeding.
      total = 6
      t = Thread.new { count_to(0, total, barrier) }

      count_to(-1, total, barrier)

      t.join
    end
  end

  def count_to(start, total, barrier)
    cur_val = start
    while (cur_val = barrier.wait_value_changed(cur_val)) < total
      barrier.mutate { |v| v + 1 }
    end

    # Allow the last counter to proceed
    barrier.mutate { |v| v + 1 }

    cur_val
  end
end
