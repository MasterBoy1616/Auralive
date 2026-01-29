import Foundation
import CoreLocation

struct Hotspot {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String
    let isActive: Bool
    let activeHours: String
    let venueType: VenueType
    
    enum VenueType: String, CaseIterable {
        case bar = "bar"
        case restaurant = "restaurant"
        case cafe = "cafe"
        case club = "club"
        case event = "event"
        
        var emoji: String {
            switch self {
            case .bar: return "🍺"
            case .restaurant: return "🍽️"
            case .cafe: return "☕"
            case .club: return "🎵"
            case .event: return "🎉"
            }
        }
        
        var displayName: String {
            switch self {
            case .bar: return "Bar"
            case .restaurant: return "Restoran"
            case .cafe: return "Kafe"
            case .club: return "Kulüp"
            case .event: return "Etkinlik"
            }
        }
    }
    
    var displayName: String {
        return "\(venueType.emoji) \(name)"
    }
    
    func distance(from location: CLLocation) -> CLLocationDistance {
        let hotspotLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location.distance(from: hotspotLocation)
    }
    
    func formattedDistance(from location: CLLocation) -> String {
        let distance = distance(from: location)
        
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
}

class HotspotManager {
    static let shared = HotspotManager()
    
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
    // Mock hotspots for demo
    private let mockHotspots = [
        Hotspot(
            id: "1",
            name: "The Local Bar",
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            address: "123 Main St, San Francisco",
            isActive: true,
            activeHours: "18:00-02:00",
            venueType: .bar
        ),
        Hotspot(
            id: "2", 
            name: "Pizza Palace",
            coordinate: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094),
            address: "456 Pizza Ave, San Francisco",
            isActive: true,
            activeHours: "11:00-23:00",
            venueType: .restaurant
        ),
        Hotspot(
            id: "3",
            name: "Coffee House",
            coordinate: CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4294),
            address: "789 Coffee St, San Francisco",
            isActive: true,
            activeHours: "07:00-22:00",
            venueType: .cafe
        ),
        Hotspot(
            id: "4",
            name: "Night Club",
            coordinate: CLLocationCoordinate2D(latitude: 37.7549, longitude: -122.4394),
            address: "321 Dance Blvd, San Francisco",
            isActive: true,
            activeHours: "21:00-04:00",
            venueType: .club
        ),
        Hotspot(
            id: "5",
            name: "Tech Meetup",
            coordinate: CLLocationCoordinate2D(latitude: 37.7949, longitude: -122.3994),
            address: "555 Innovation Way, San Francisco",
            isActive: true,
            activeHours: "19:00-22:00",
            venueType: .event
        )
    ]
    
    private init() {
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        guard CLLocationManager.locationServicesEnabled() else {
            print("❌ Location services not enabled")
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    func getNearbyHotspots(within radius: CLLocationDistance = 1000) -> [Hotspot] {
        guard let location = currentLocation else {
            print("⚠️ Current location not available, returning mock data")
            return mockHotspots
        }
        
        return mockHotspots.filter { hotspot in
            hotspot.distance(from: location) <= radius
        }.sorted { hotspot1, hotspot2 in
            hotspot1.distance(from: location) < hotspot2.distance(from: location)
        }
    }
    
    func getActiveHotspots() -> [Hotspot] {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        
        return getNearbyHotspots().filter { hotspot in
            // Simple active hours check (in a real app, this would be more sophisticated)
            if hotspot.venueType == .bar || hotspot.venueType == .club {
                return hour >= 18 || hour <= 2 // 6 PM to 2 AM
            } else if hotspot.venueType == .cafe {
                return hour >= 7 && hour <= 22 // 7 AM to 10 PM
            } else {
                return hour >= 11 && hour <= 23 // 11 AM to 11 PM
            }
        }
    }
    
    func getHotspot(by id: String) -> Hotspot? {
        return mockHotspots.first { $0.id == id }
    }
    
    func isInHotspotRange(hotspotId: String, maxDistance: CLLocationDistance = 100) -> Bool {
        guard let location = currentLocation,
              let hotspot = getHotspot(by: hotspotId) else {
            return false
        }
        
        return hotspot.distance(from: location) <= maxDistance
    }
    
    func checkAutoJoinHotspots() -> Hotspot? {
        let nearbyHotspots = getNearbyHotspots(within: 50) // 50 meters for auto-join
        
        for hotspot in nearbyHotspots {
            if isInActiveHours(hotspot: hotspot) {
                return hotspot
            }
        }
        
        return nil
    }
    
    private func isInActiveHours(hotspot: Hotspot) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        
        // Simple active hours check
        switch hotspot.venueType {
        case .bar, .club:
            return hour >= 18 || hour <= 2
        case .cafe:
            return hour >= 7 && hour <= 22
        case .restaurant:
            return hour >= 11 && hour <= 23
        case .event:
            return hour >= 19 && hour <= 22
        }
    }
    
    // MARK: - Group Chat Integration
    
    func joinHotspotGroupChat(hotspot: Hotspot) -> Bool {
        guard isInHotspotRange(hotspotId: hotspot.id, maxDistance: 200) else {
            print("❌ Too far from hotspot to join group chat")
            return false
        }
        
        // Award crystals for venue check-in
        CrystalManager.shared.awardVenueCheckin()
        
        print("✅ Joined group chat for \(hotspot.name)")
        return true
    }
    
    func leaveHotspotGroupChat(hotspot: Hotspot) {
        print("👋 Left group chat for \(hotspot.name)")
    }
    
    // MARK: - Mock Data Helpers
    
    func addMockLocation() {
        // Set a mock location for testing (San Francisco)
        currentLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        print("📍 Mock location set: San Francisco")
    }
}

// MARK: - CLLocationManagerDelegate
extension HotspotManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        // Check for auto-join hotspots
        if let autoJoinHotspot = checkAutoJoinHotspots() {
            NotificationCenter.default.post(
                name: .hotspotAutoJoinAvailable,
                object: autoJoinHotspot
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
        
        // Fallback to mock location for demo
        addMockLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location permission granted")
            startLocationUpdates()
        case .denied, .restricted:
            print("❌ Location permission denied")
            addMockLocation() // Use mock data for demo
        case .notDetermined:
            print("⚠️ Location permission not determined")
        @unknown default:
            print("⚠️ Unknown location authorization status")
        }
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let hotspotAutoJoinAvailable = Notification.Name("hotspotAutoJoinAvailable")
    static let hotspotJoined = Notification.Name("hotspotJoined")
    static let hotspotLeft = Notification.Name("hotspotLeft")
}