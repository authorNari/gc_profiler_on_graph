if (ENV['RAILS_ENV'] == 'development')
  GC::Profiler.enable
  require_dependency "gc_profiler_on_graph"
  class ActionController::Base
    after_filter GCProfilerOnGraph::Filter
  end
end
