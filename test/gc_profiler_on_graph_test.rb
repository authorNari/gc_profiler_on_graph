require "#{File.dirname(__FILE__)}/test_helper"
require "#{File.dirname(__FILE__)}/../lib/gc_profiler_on_graph"

class GcProfilerOnGraphTest < ActiveSupport::TestCase
  def setup
    GC::Profiler.enable
  end

  test "parse gc prof" do
    GC.start
    res = GCProfilerOnGraph::Filter.parse_profile
    assert_not_nil res[:invokes]
    size = res[:invoke_time].size
    assert_equal size, res[:invoke_time].size
    assert_equal size, res[:total_size].size
    assert_equal size, res[:use_size].size
    assert_equal size, res[:total_object].size
    assert_equal size, res[:gc_time].size
#     %w(index invoke_time use_size total_size total_object gc_time).each{|e| puts res[e.to_sym] }
  end

  test "insert graphs" do
#     GC.start
#     GCProfilerOnGraph::Filter.insert_graphs
  end
end
