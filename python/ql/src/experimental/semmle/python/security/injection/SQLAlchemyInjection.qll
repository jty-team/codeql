import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.RemoteFlowSources
import semmle.python.ApiGraphs
import experimental.semmle.python.frameworks.Stdlib

class SqlAlchemyInjectionConfig extends TaintTracking::Configuration {
  SqlAlchemyInjectionConfig() { this = "SqlAlchemyInjectionConfig" }

  override predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource }

  override predicate isSink(DataFlow::Node sink) { sink instanceof SqlAlchemyInjectionSink }

  override predicate isSanitizer(DataFlow::Node sanitizer) {
    sanitizer = any(SqlSanitizer SqlSanitizer).getSanitizerNode()
  }
}
