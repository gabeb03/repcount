// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

extension RepcountAPI {
  struct NestedUpdateUserInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      googleImageUrl: GraphQLNullable<String> = nil,
      firstName: GraphQLNullable<String> = nil,
      password: GraphQLNullable<String> = nil,
      emailVerificationTokenExpiration: GraphQLNullable<DateTime> = nil,
      emailVerified: GraphQLNullable<Bool> = nil,
      profilePicture: GraphQLNullable<StoredFileInput> = nil,
      googleProfileId: GraphQLNullable<String> = nil,
      emailVerificationToken: GraphQLNullable<String> = nil,
      lastName: GraphQLNullable<String> = nil,
      resetPasswordTokenExpiration: GraphQLNullable<DateTime> = nil,
      lastSignedIn: GraphQLNullable<DateTime> = nil,
      resetPasswordToken: GraphQLNullable<String> = nil,
      email: GraphQLNullable<String> = nil,
      id: GadgetID
    ) {
      __data = InputDict([
        "googleImageUrl": googleImageUrl,
        "firstName": firstName,
        "password": password,
        "emailVerificationTokenExpiration": emailVerificationTokenExpiration,
        "emailVerified": emailVerified,
        "profilePicture": profilePicture,
        "googleProfileId": googleProfileId,
        "emailVerificationToken": emailVerificationToken,
        "lastName": lastName,
        "resetPasswordTokenExpiration": resetPasswordTokenExpiration,
        "lastSignedIn": lastSignedIn,
        "resetPasswordToken": resetPasswordToken,
        "email": email,
        "id": id
      ])
    }

    var googleImageUrl: GraphQLNullable<String> {
      get { __data["googleImageUrl"] }
      set { __data["googleImageUrl"] = newValue }
    }

    var firstName: GraphQLNullable<String> {
      get { __data["firstName"] }
      set { __data["firstName"] = newValue }
    }

    var password: GraphQLNullable<String> {
      get { __data["password"] }
      set { __data["password"] = newValue }
    }

    var emailVerificationTokenExpiration: GraphQLNullable<DateTime> {
      get { __data["emailVerificationTokenExpiration"] }
      set { __data["emailVerificationTokenExpiration"] = newValue }
    }

    var emailVerified: GraphQLNullable<Bool> {
      get { __data["emailVerified"] }
      set { __data["emailVerified"] = newValue }
    }

    var profilePicture: GraphQLNullable<StoredFileInput> {
      get { __data["profilePicture"] }
      set { __data["profilePicture"] = newValue }
    }

    var googleProfileId: GraphQLNullable<String> {
      get { __data["googleProfileId"] }
      set { __data["googleProfileId"] = newValue }
    }

    var emailVerificationToken: GraphQLNullable<String> {
      get { __data["emailVerificationToken"] }
      set { __data["emailVerificationToken"] = newValue }
    }

    var lastName: GraphQLNullable<String> {
      get { __data["lastName"] }
      set { __data["lastName"] = newValue }
    }

    var resetPasswordTokenExpiration: GraphQLNullable<DateTime> {
      get { __data["resetPasswordTokenExpiration"] }
      set { __data["resetPasswordTokenExpiration"] = newValue }
    }

    var lastSignedIn: GraphQLNullable<DateTime> {
      get { __data["lastSignedIn"] }
      set { __data["lastSignedIn"] = newValue }
    }

    var resetPasswordToken: GraphQLNullable<String> {
      get { __data["resetPasswordToken"] }
      set { __data["resetPasswordToken"] = newValue }
    }

    var email: GraphQLNullable<String> {
      get { __data["email"] }
      set { __data["email"] = newValue }
    }

    var id: GadgetID {
      get { __data["id"] }
      set { __data["id"] = newValue }
    }
  }

}