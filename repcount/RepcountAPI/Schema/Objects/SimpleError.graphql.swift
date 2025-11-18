// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension RepcountAPI.Objects {
  /// This Error object is returned for errors which don't have other specific handling. It has a message which is safe to display to users, but is often technical in nature. It also has a `code` field which is documented in the Gadget API Error Codes docs.
  static let SimpleError = ApolloAPI.Object(
    typename: "SimpleError",
    implementedInterfaces: [RepcountAPI.Interfaces.ExecutionError.self],
    keyFields: nil
  )
}