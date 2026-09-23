# UI Consistency Notes — AccoFinder

These are my notes from going through the whole UI before handing any of this to the
team. I built the **dashboard**, **auth**, **notifications** and **properties**
features, and they all follow one look and one way of doing things. When I reviewed
the other features (bookings, payments, disputes, home, reviews, settings) against
them, I found a lot that doesn't match. Here is everything that stood out, in plain
English, so we can fix it with no excuses about unclear direction.

---

## The house style I already set (this is the bar)

Every screen I made follows these rules, and everything else should too:

1. **The screen wrapper contract.** Each screen is an `Item` that exposes
   `pageTitle` (wrapped in `qsTr`), `showHeader`, `showBack`, `showBottomBorder`,
   `titleFontSize`, `isSearchBar`, `searchReadOnly`, a `goBack()`, and a
   `rightComponentAction` that puts the `AppNotificationBell` in the header.
   See `ui/features/dashboards/admins/screens/AdminsDashboardScreen.qml`,
   `ui/features/properties/screens/MyPropertiesScreen.qml` and
   `ui/features/notifications/screens/NotificationsScreen.qml`.

2. **One shared scroll shell.** I built `AppScrollablePage`
   (`ui/components/pages/AppScrollablePage.qml`) — the `#F8FAFC` background, centered
   content capped at 520px, pull-to-refresh, built-in spinner. My screens sit inside
   it. New screens should never re-invent this.

3. **One colour palette.** `primary #2563EB`, `primaryDark #1D4ED8`, page bg
   `#F8FAFC`, surface `#FFFFFF`, border `#E5E7EB`, text `#1F2937`, muted `#6B7280`.
   I repeat these as `readonly property color` on each page.

4. **The same shared parts.** `SectionHeader`, `StatCard`, `AppEmptyState`,
   `AppTextInput`, `AppSearchBar`, `AppSpinner`, `AppScrollBar`, and the gradient
   hero card you see on the dashboards, Profile and CreateAccount.

5. **The same loading/refresh rhythm.** `refresh()` → wait for the view-model
   `onIsLoadingChanged` → `onRequestsSettled()` with a minimum spinner time.

---

## 1. Bookings — old style, broken routes, empty stubs

- `ui/features/bookings/screens/BookingsScreen.qml` — the title "Bookings" is not in
  `qsTr`, and the screen is missing the rest of my header contract
  (`showBottomBorder`, `titleFontSize`, `searchReadOnly`, `goBack()`) and there is no
  notification bell in the header.
- `ui/features/bookings/pages/BookingPage.qml` — uses `#F4F6F9` for the background
  instead of my `#F8FAFC`, hard-codes hex colours instead of the palette, and uses a
  plain `Button` instead of the shared button style.
- `ui/features/bookings/pages/BookingView.qml` — this is clearly an old prototype:
  hard-coded dummy bookings with Unsplash photo URLs, `#F4F6F9` background, legacy
  filter chips, and a commented-out header. None of my loading / refresh / empty-state
  pattern, no header contract, no view model.
- **Empty stubs (5 lines each):** `BookingListScreen.qml`, `CreateBookingScreen.qml`,
  `BookingDetailsScreen.qml`, `BookingsListPage.qml`, `CreateBookingPage.qml`.
- **Broken routes** in `ui/utils/NavigationUtils.js` point at files that don't exist:
  `pages/PendingBookingsPage.qml`, `pages/CancelledBookingsPage.qml` and
  `pages/ConfirmedBokingsPage.qml` (also misspelled — "Bokings").

## 2. Payments — demo code and empty stubs

- `ui/features/payments/screens/PaymentsScreen.qml` — a bare `Item` with no
  `pageTitle` / header contract at all.
- `ui/features/payments/pages/PaymentsPage.qml` — builds its **own** `ToolBar` header
  (with `back.png` and a MouseArea) instead of going through `AppHeader`. The content
  is hard-coded placeholder text ("MK 85,000", `color:"blue"`, `color:"red"`). This is
  leftover prototype code, plain and simple.
- `ui/features/payments/screens/PaymentStatusScreen.qml` — again builds its own
  `ToolBar`, bypasses the shared header, and uses old-style imports (`QtQuick 2.15`,
  `QtQuick.Controls 2.15`, `QtQuick.Layouts 1.15`).
- **Empty stubs:** `PaymentScreen.qml`, `PaymetHistoryScreen.qml` (misspelled),
  `PaymentStatusPage.qml`, `PaymentsHistoryPage.qml`, `PaymentModel.qml`,
  `PaymentDelegate.qml`.

## 3. Disputes — half-converted

`ui/features/disputes/screens/DisputesScreen.qml` has my new refresh/loading logic but
does **not** use `AppScrollablePage` — it re-implements its own `Page` + `Flickable` +
pull-to-refresh + `AppSpinner` overlay, which I already centralised and shouldn't be
duplicated.

`ui/features/disputes/pages/DisputesPage.qml` hand-rolls its empty state (icon circle +
labels) instead of using the shared `AppEmptyState`.

- **Empty stubs:** `DisputeListScreen.qml`, `CreateDisputeScreen.qml`,
  `CreateDisputePage.qml`, `DisputesListPage.qml`, `DisputeCard.qml`.

## 4. Home — a completely different, self-built header

`HomeScreen.qml` opts out of the shared header (`showHeader: false`) and uses a
home-made `HeaderComponent` (`ui/features/home/components/HeaderComponent.qml`) with
fixed-pixel collapsing math and a plain `notification.svg` icon instead of the
`AppNotificationBell` I use everywhere else.

- `ui/features/home/pages/HomePage.qml` — white background instead of `#F8FAFC`,
  SwipeView tabs, no header contract, no pull-to-refresh / loading / empty state.
- `ui/features/home/pages/AllPage.qml` — hard-coded `#F5F5F5` dividers, a fixed
  3-column Flow layout, no loading skeleton, no empty or error states.
- **Empty stubs:** `PropertyEmptyState.qml`, `PropertyFilterBar.qml`,
  `PropertyLoadingSkeleton.qml`, `StickyActionBar.qml`, `WelcomeHeader.qml`,
  `RecentBooking.qml`, `HomeModel.qml`, `HomeDelegate.qml`, `PropertyListDelegate.qml`,
  `PropertyCategoryModel.qml`.

## 5. Reviews — the feature is empty and can't even be opened

Every file is a 5-line stub: `ReviewsScreen.qml`, `ReviewListScreen.qml`,
`WriteReviewScreen.qml`, `ReviewsPage.qml`, `ReviewsListPage.qml`,
`WriteReviewsPage.qml`, `ReviewForm.qml`, `ReviewDelegate.qml`.

On top of that it's unreachable: `navigateToReviews()` in `NavigationUtils.js` points
at `../features/disputes/screens/ReviewsScreen.qml` — the wrong folder.

## 6. Settings — the whole feature is an empty stub

`SettingsScreen.qml`, `SettingsPage.qml`, `SettingsDelegate.qml`, `SettingsModel.qml`
are all 5-line stubs, so the Settings tab renders a blank page.

## 7. Header / navigation problems worth flagging

- Two header systems now exist: the shared `AppHeader` (the one I used) versus the
  hand-made `ToolBar`s in `PaymentsPage.qml` and `PaymentStatusScreen.qml`. New
  screens go through `AppHeader`, never build their own.
- `ui/components/navigations/AppBottomNavBar.qml` is dead code — the real footer is
  `ui/features/home/components/FooterComponent.qml`. Two navigation-bar components
  exist and only one is actually used.
- The footer paints inactive tab icons with a literal `"gray"` instead of a palette
  colour.

## 8. NavigationUtils routes that point at nothing

These will silently fail (blank screen / console warning) if a user taps them:
- Pending bookings screen (missing)
- Cancelled bookings screen (missing)
- Confirmed bookings screen (missing + typo)
- `navigateToReviews()` → reviews screen under `disputes/` (wrong folder)
- `navigateToAdmins()` → `auth/admins/screens/OtpScree.qml` (wrong folder; the real
  file is `auth/screens/OtpScree.qml`)
- `navigateToDashboard(role)` → `dashboard/screens/...` (wrong folder; the folder is
  `dashboards`, and `ClientsDashboardScreen.qml` does not exist at all)

## 9. General conventions that drifted

- **Imports:** my files use `import QtQuick` (versions auto-managed); older screens
  still force `QtQuick 2.15`, `QtQuick.Controls 2.15`, `QtQuick.Layouts 1.15`.
- **Translation:** I wrap every user-facing string in `qsTr(...)`; older screens leave
  strings raw ("Payment summary", "Payment status", "Bookings").
- **Backgrounds:** the standard is `#F8FAFC`; I keep seeing `#F4F6F9`, `#FFFFFF` and
  `#F5F5F5` in the other features.
- **Empty states / loading / pull-to-refresh** have now been re-implemented three
  different ways (AppScrollablePage, MyPropertiesSection's Flickable, DisputesScreen's
  Flickable). That's exactly the duplication I don't want — there is one shared
  component, so use it.

---

## How I'd like us to tackle it

1. Fix `NavigationUtils.js` so every route points at a real file, and clean up the two
   misspelled/stale resource files.
2. Build Reviews and Settings on the same pattern (screen contract +
   `AppScrollablePage` + notification bell) so they match my features out of the box.
3. Rewrite the old/demo screens (Payments, Bookings) to use `AppHeader`, the palette,
   `AppEmptyState` and my view-model loading/refresh rhythm.
4. Bring Home in line with the shared header and `AppScrollablePage` — or if we keep
   it as a special "client landing" experience on purpose, at least share the palette,
   colours and the notification bell.
5. Delete the duplicated `AppBottomNavBar` and the hand-rolled Flickable
   pull-to-refresh code so there is exactly one way to do things.