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
flutter pub get

## AI Usage Log

**Tool Used:** ChatGPT  
**Purpose:** Learning support, debugging assistance, and development guidance

---

### Entry 1
**Date:** December 13, 2025  
**Time:** ~1:00 PM – 4:00 PM  
**Task:** Project setup & planning  

**AI Assistance Used For:**
- Identifying appropriate Firebase services (Authentication, Firestore)  

**How It Was Used:**  
AI suggestions were used to guide planning and structure. All implementation decisions were made and executed by me, Luna Da Silva.

---

### Entry 2
**Date:** December 13, 2025  
**Time:** ~4:00 PM – 7:00 PM  
**Task:** Firebase Authentication & role-based navigation  

**AI Assistance Used For:**
- Debugging authentication-related errors  
- Understanding role-based routing (customer, restaurant, driver)  

**How It Was Used:**  
AI was used to explain errors and provide example logic, which was then manually implemented and adjusted.

---

### Entry 3
**Date:** December 14, 2025  
**Time:** ~10:00 AM – 2:00 PM  
**Task:** Firestore queries & real-time data handling  

**AI Assistance Used For:**
- Debugging Firestore composite index errors  
- Understanding real-time listeners and query constraints  
- Structuring collections for orders and menu items  

**How It Was Used:**  
AI explanations were used to understand Firebase behavior. Queries and database updates were implemented manually.

---

### Entry 4
**Date:** December 14, 2025  
**Time:** ~2:00 PM – 6:00 PM  
**Task:** UI development & workflow integration  

**AI Assistance Used For:**
- Flutter widget structuring and navigation fixes  
- Debugging rendering and routing issues

**How It Was Used:**  
AI-generated suggestions were selectively adopted and customized to fit the project’s architecture.

---

### Entry 5
**Date:** December 14, 2025  
**Time:** ~6:00 PM – 9:00 PM  
**Task:** Documentation, demo preparation, and deployment guidance  

**AI Assistance Used For:**
- GitHub version control troubleshooting and APK build guidance  

**How It Was Used:**  
AI was used to assist with clarity and workflow explanations. All final materials were reviewed and finalized by me, Luna Da Silva.

---

### Summary
AI tools were used as a learning and productivity aid to support debugging, understanding frameworks, and improving development efficiency. All code, design decisions, and documentation were reviewed, adapted, and implemented by the developer to ensure originality and full understanding.
