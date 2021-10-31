---
title: Channel list helper views
---

## Changing the loading view

While the channels are loaded, a loading view is displayed, with a simple animating activity indicator. If you want to change this view, with your own custom view, you will need to implement the `makeLoadingView` of the `ViewFactory` protocol.

```swift
class CustomFactory: ViewFactory {
    
    @Injected(\.chatClient) public var chatClient
    
    private init() {}
    
    public static let shared = CustomFactory()
    
    func makeLoadingView() -> some View {
        VStack {
            Text("This is custom loading view")
            ProgressView()
        }
    }
}    
```
 
 Afterwards, you will need to inject the newly created `CustomFactory` into our view hierarchy.

```swift
var body: some Scene {
    WindowGroup {
        ChatChannelListView(viewFactory: CustomFactory.shared)
    }
}
```

## Changing the no channels available view

When there are no channels available, the SDK displays a screen with a button to start a chat. If you want to replace this screen, you will just need to implement the `makeNoChannelsView` in the `ViewFactory`.

```swift
func makeNoChannelsView() -> some View {
    VStack {
        Spacer()
        Text("This is our own custom no channels view.")
        Spacer()
    }
}
```