# The Food Runner (Food Delivery Platform)

## Team
- Luna Da Silva (GitHub: lunadasil)

## Demo Video
- Link: https://youtu.be/TE-DUuEXhWI

## Project Summary
The Food Runner is a multi-role food delivery platform with three user experiences:
- **Customer**: browse restaurants, view menus, place orders, track order status in real time
- **Restaurant**: manage incoming orders and update order status (new → preparing → ready)
- **Driver**: view ready orders, accept deliveries, mark orders delivered

The app uses **Firebase Authentication** for login and **Cloud Firestore** for real-time data synchronization.

---

## Features Implemented
### Authentication (Multi-Role)
- Email/password login and registration
- Role stored in Firestore `/users/{uid}`
- Role-based routing to customer/restaurant/driver dashboards

### Customer
- Restaurant list from Firestore
- Menu browsing (menuItems subcollection)
- Add items to cart + place order
- Order tracking screen with real-time status updates

### Restaurant
- View orders for a restaurant
- Update order status: **preparing**, **ready**
- Real-time updates visible to customer immediately

### Driver
- View available orders (status = ready)
- Accept order (assign driverId + set picked_up)
- Mark delivered (status = delivered)

---

## Technology Stack
- **Flutter/Dart** (UI + app logic)
- **Firebase Authentication** (user sign-in)
- **Cloud Firestore** (database + real-time listeners)
- **go_router** (navigation/routing)

---

## Database Structure (Firestore)
- `users/{uid}`
  - `email`, `role`, `createdAt`
- `restaurants/{restaurantId}`
  - `name`, `category`, `etaMins`
- `restaurants/{restaurantId}/menuItems/{itemId}`
  - `name`, `description`, `price`, `isAvailable`, `createdAt`
- `orders/{orderId}`
  - `customerId`, `restaurantId`, `driverId?`, `status`, `items[]`, `total`, `createdAt`

---

## How to Run
### Prereqs
- Flutter installed
- Firebase project configured
- Firestore + Authentication enabled

### Install dependencies
```bash
flutter pub get
