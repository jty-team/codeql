/**
 * Provides classes modeling security-relevant aspects of the standard libraries.
 * Note: some modeling is done internally in the dataflow/taint tracking implementation.
 */

private import python
private import semmle.python.dataflow.new.DataFlow
private import semmle.python.dataflow.new.TaintTracking
private import semmle.python.dataflow.new.RemoteFlowSources
private import experimental.semmle.python.Concepts
private import semmle.python.Concepts
private import semmle.python.ApiGraphs

private module SQLAlchemy {
  private class SqlAlchemyQuerySinkMethods extends string {
    SqlAlchemyQuerySinkMethods() { this in [
        "filter", "filter_by", "having", "group_by", "order_by"
      ]
    }
  }

  private API::Node sqlAlchemySessionInstance() {
    result = API::moduleImport("sqlalchemy.orm").getMember("Session").getReturn() or
    result = API::moduleImport("sqlalchemy.orm").getMember("sessionmaker").getReturn().getReturn()
  }

  private API::Node sqlAlchemyQueryInstance() {
    result = sqlAlchemySessionInstance().getMember("query").getReturn()
  }

  private API::Node sqlAlchemyEngineInstance() {
    result = API::moduleImport("sqlalchemy").getMember("create_engine").getReturn()
  }

  private class SqlAlchemyQuerySink extends DataFlow::CallCfgNode, SqlExecution::Range {
    DataFlow::Node sql;

    SqlAlchemyQuerySink() {
      this in [
        sqlAlchemyQueryInstance().getMember(any(SqlAlchemyQuerySinkMethods sinkMethod)).getACall(),
        sqlAlchemySessionInstance().getMember("execute").getACall(),
        sqlAlchemySessionInstance().getMember("scalar").getACall()
        sqlAlchemyEngineInstance().getMember("connect").getReturn().getMember("execute").getACall(),
        sqlAlchemyEngineInstance().getMember("begin").getReturn().getMember("execute").getACall()
      ] and
      sql = this.getArg(0)
    }

    override DataFlow::Node getSql() { result = sql }
  }

  private class SqlSanitizerCall extends DataFlow::CallCfgNode, NoSQLSanitizer::Range {
    SqlSanitizerCall() {
      this =
        API::moduleImport("sqlescapy").getMember("sqlescape").getACall()
    }

    override DataFlow::Node getSanitizerNode() { result = this.getArg(0) }
  }
}
