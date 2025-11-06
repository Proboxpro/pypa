import MapKit
import SwiftUI
import CoreLocation

struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
        
    var coordinates: ((Double, Double), (Double, Double))
    var names: (String, String)

    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator()
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        let fromLat = coordinates.0.0
        let fromLon = coordinates.0.1
        let toLat = coordinates.1.0
        let toLon = coordinates.1.1
        
        let isFromValid = fromLat != 0 && fromLon != 0 && abs(fromLat) <= 90 && abs(fromLon) <= 180
        let isToValid = toLat != 0 && toLon != 0 && abs(toLat) <= 90 && abs(toLon) <= 180
        
        if !isFromValid || !isToValid {
            return mapView
        }

        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: fromLat, longitude: fromLon),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        mapView.setRegion(region, animated: true)
          
        let p1 = MKPointAnnotation()
        p1.coordinate = CLLocationCoordinate2D(latitude: fromLat, longitude: fromLon)
        p1.title = names.0

        
        let p2 = MKPointAnnotation()
        p2.coordinate = CLLocationCoordinate2D(latitude: toLat, longitude: toLon)
        p2.title = names.1

        mapView.addAnnotations([p1, p2])
        
        func createArcCoordinates(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, numberOfPoints: Int = 50) -> [CLLocationCoordinate2D] {
            var coordinates: [CLLocationCoordinate2D] = []
            
            let lat1 = from.latitude * .pi / 180
            let lon1 = from.longitude * .pi / 180
            let lat2 = to.latitude * .pi / 180
            let lon2 = to.longitude * .pi / 180
            
            for i in 0...numberOfPoints {
                let fraction = Double(i) / Double(numberOfPoints)
                
                // формула для расчета точки на дуге большого круга
                let d = acos(sin(lat1) * sin(lat2) + cos(lat1) * cos(lat2) * cos(lon2 - lon1))
                
                if d == 0 {
                    coordinates.append(from)
                    continue
                }
                
                let a = sin((1 - fraction) * d) / sin(d)
                let b = sin(fraction * d) / sin(d)
                
                let x = a * cos(lat1) * cos(lon1) + b * cos(lat2) * cos(lon2)
                let y = a * cos(lat1) * sin(lon1) + b * cos(lat2) * sin(lon2)
                let z = a * sin(lat1) + b * sin(lat2)
                
                let lat = atan2(z, sqrt(x * x + y * y)) * 180 / .pi
                let lon = atan2(y, x) * 180 / .pi
                
                coordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
            }
            
            return coordinates
        }
        
        // показ пунктирной дуги между точками
        func showDirectLine() {
            let arcCoordinates = createArcCoordinates(from: p1.coordinate, to: p2.coordinate)
            let arcLine = MKPolyline(coordinates: arcCoordinates, count: arcCoordinates.count)
            mapView.addOverlay(arcLine)
            
            var region = MKCoordinateRegion()
            region.center.latitude = (fromLat + toLat) / 2
            region.center.longitude = (fromLon + toLon) / 2
            region.span.latitudeDelta = abs(fromLat - toLat) * 1.5
            region.span.longitudeDelta = abs(fromLon - toLon) * 1.5
            
            if region.span.latitudeDelta < 0.1 {
                region.span.latitudeDelta = 0.1
            }
            if region.span.longitudeDelta < 0.1 {
                region.span.longitudeDelta = 0.1
            }
            
            mapView.setRegion(region, animated: true)
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: p1.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: p2.coordinate))
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                showDirectLine()
                return
            }
            
            guard let response = response else {
                showDirectLine()
                return
            }
            
            guard let route = response.routes.first else {
                showDirectLine()
                return
            }
            
            mapView.addOverlay(route.polyline)
            mapView.setVisibleMapRect(
                route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                animated: true)
        }
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }

    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5
            

            if let polyline = overlay as? MKPolyline {
                let pointCount = polyline.pointCount
                if pointCount > 2 {
                    renderer.lineDashPattern = [2, 5]
                }
            }
            
            return renderer
        }
    }
}
