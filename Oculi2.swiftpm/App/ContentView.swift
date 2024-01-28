import SwiftUI

struct ContentView: View {
    @ObservedObject var navigationModel: NavigationModel = NavigationModel()
    @EnvironmentObject var handModel: HandTrackerModel

    public var body: some View {
        if let currentPage = navigationModel.navigationStack.last {
            currentPage.page
                .environmentObject(navigationModel)
        } else {
           EmptyView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
