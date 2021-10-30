---
title: SwiftUI Overview
---

## Overview 

The SwiftUI SDK is built on top of the `StreamChat` framework and it's a SwfitUI alternative to the `StreamChatUI` SDK. It's built completely in SwiftUI, using declarative patterns, that will be familiar to developers working with SwiftUI. The SDK includes an extensive set of performant and customizable UI components which allow you to get started quickly with little to no plumbing required.

## Architecture

The SwiftUI SDK offers three types of components:

- Screens - Easiest to integrate, but offer small customizations, like branding and text changes.
- Stateful components - Offer more customization options and possibility to inject custom views. Also fairly simple to integrate, if the extension points are suitable for your chat use-case. These components come with view models.
- Stateless components - These are the building blocks for the other two types of components. In order to use them, you would have to provide the state and data. Using these components only make sense if you want to implement completely custom chat experience. 