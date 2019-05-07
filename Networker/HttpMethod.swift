import Foundation

public enum HttpMethod: Equatable {
  case get
  case put
  case acl
  case head
  case post
  case copy
  case lock
  case move
  case bind
  case link
  case patch
  case trace
  case mkcol
  case merge
  case purge
  case notify
  case search
  case unlock
  case rebind
  case unbind
  case report
  case delete
  case unlink
  case connect
  case msearch
  case options
  case propfind
  case checkout
  case proppatch
  case subscribe
  case mkcalendar
  case mkactivity
  case unsubscribe
  case source
  case raw(value: String)
}

internal extension HttpMethod {
  var rawValue: String {
    switch self {
    case .get:
      return "GET"
    case .put:
      return "PUT"
    case .acl:
      return "ACL"
    case .head:
      return "HEAD"
    case .post:
      return "POST"
    case .copy:
      return "COPY"
    case .lock:
      return "LOCK"
    case .move:
      return "MOVE"
    case .bind:
      return "BIND"
    case .link:
      return "LINK"
    case .patch:
      return "PATCH"
    case .trace:
      return "TRACE"
    case .mkcol:
      return "MKCOL"
    case .merge:
      return "MERGE"
    case .purge:
      return "PURGE"
    case .notify:
      return "NOTIFY"
    case .search:
      return "SEARCH"
    case .unlock:
      return "UNLOCK"
    case .rebind:
      return "REBIND"
    case .unbind:
      return "UNBIND"
    case .report:
      return "REPORT"
    case .delete:
      return "DELETE"
    case .unlink:
      return "UNLINK"
    case .connect:
      return "CONNECT"
    case .msearch:
      return "MSEARCH"
    case .options:
      return "OPTIONS"
    case .propfind:
      return "PROPFIND"
    case .checkout:
      return "CHECKOUT"
    case .proppatch:
      return "PROPPATCH"
    case .subscribe:
      return "SUBSCRIBE"
    case .mkcalendar:
      return "MKCALENDAR"
    case .mkactivity:
      return "MKACTIVITY"
    case .unsubscribe:
      return "UNSUBSCRIBE"
    case .source:
      return "SOURCE"
    case let .raw(value):
      return value
    }
  }
}
