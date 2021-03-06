import XCTest
import Nimble
import BrightFutures
import Result
@testable import KataLogInLogOutSwift

class PresenterTests: XCTestCase {

    private static let anyUsername = "user"
    private static let anyPassword = "pass"

    private var kata: MockKataLogInLogOut!
    private var view: MockView!
    private var presenter: Presenter!

    override func setUp() {
        super.setUp()
        self.kata = MockKataLogInLogOut()
        self.view = MockView()
        self.presenter = Presenter(kataLogInLogOut: kata, view: view)
    }

    func testShowsAnInvalidCredentialsErrorIfTheLogInReturnsInvalidCredentials() {
        givenTheLogInProcessReturns(Result(error: LogInError.invalidCredentials))

        presenter.didTapLogInButton(username: PresenterTests.anyUsername, password: PresenterTests.anyPassword)

        expect(self.view.errorMessageShown).toEventually(equal("Invalid credentials"))
    }

    func testShowsAnInvalidUsernameErrorIfTheLogInReturnsInvalidCredentials() {
        givenTheLogInProcessReturns(Result(error: LogInError.invalidUsername))

        presenter.didTapLogInButton(username: PresenterTests.anyUsername, password: PresenterTests.anyPassword)

        expect(self.view.errorMessageShown).toEventually(equal("Invalid username"))
    }

    func testShowsACouldNotPerformLogOutIfTheLogOutProcessFailed() {
        givenTheLogOutProcessReturns(false)

        presenter.didTapLogOutButton()

        expect(self.view.errorMessageShown).toEventually(equal("Log out error"))
    }

    func testHidesTheLogInFormAndShowsTheLogOutFormIfTheLogInProcessFinishProperly() {
        givenTheLogInProcessReturns(Result(value: PresenterTests.anyUsername))

        presenter.didTapLogInButton(username: PresenterTests.anyUsername, password: PresenterTests.anyPassword)

        expect(self.view.didHideLogInForm).toEventually(beTrue())
        expect(self.view.didShowLogOutForm).toEventually(beTrue())
    }

    func testHidesTheLogOutFormAndShowsTheLogInFormIfTheLogOutProcessFinishProperly() {
        givenTheLogOutProcessReturns(true)

        presenter.didTapLogOutButton()

        expect(self.view.didHideLogOutForm).toEventually(beTrue())
        expect(self.view.didShowLogInForm).toEventually(beTrue())
    }

    private func givenTheLogInProcessReturns(_ result: Result<String, LogInError>) {
        kata.mockedLogInResult = result
    }

    private func givenTheLogOutProcessReturns(_ result: Bool) {
        kata.mockedLogOutResult = result
    }
}

class MockKataLogInLogOut: KataLogInLogOut {

    var mockedLogInResult: Result<String, LogInError>!
    var mockedLogOutResult: Bool!

    init() {
        super.init(clock: Clock())
    }

    override func logIn(username: String, password: String) -> Future<String, LogInError> {
        return Future(result: mockedLogInResult)
    }

    override func logOut() -> Bool {
        return mockedLogOutResult
    }
}

class MockView: View {

    var errorMessageShown: String?
    var didShowLogInForm: Bool = false
    var didShowLogOutForm: Bool = false
    var didHideLogInForm: Bool = false
    var didHideLogOutForm: Bool = false

    func showError(message: String) {
        errorMessageShown = message
    }
    func showLogInForm() {
        didShowLogInForm = true
    }
    func hideLogInForm() {
        didHideLogInForm = true
    }
    func showLogOutForm() {
        didShowLogOutForm = true
    }
    func hideLogOutForm() {
        didHideLogOutForm = true
    }
}
