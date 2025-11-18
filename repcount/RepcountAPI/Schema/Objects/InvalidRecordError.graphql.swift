// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension RepcountAPI.Objects {
  /// This object is returned as an error when a record doesn't pass the defined validations on the model. The validation messages for each of the invalid fields are available via the other fields on this error type.
  static let InvalidRecordError = ApolloAPI.Object(
    typename: "InvalidRecordError",
    implementedInterfaces: [RepcountAPI.Interfaces.ExecutionError.self],
    keyFields: nil
  )
}