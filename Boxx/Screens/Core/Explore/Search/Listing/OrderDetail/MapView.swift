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

        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: coordinates.0.0, longitude: coordinates.0.1),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        mapView.setRegion(region, animated: true)
          
        let p1 = MKPointAnnotation()
        p1.coordinate = CLLocationCoordinate2D(latitude: coordinates.0.0, longitude: coordinates.0.1)
        p1.title = names.0

        
        let p2 = MKPointAnnotation()
        p2.coordinate = CLLocationCoordinate2D(latitude: coordinates.1.0, longitude: coordinates.1.1)
        p2.title = names.1

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: p1.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: p2.coordinate))
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
          guard let route = response?.routes.first else { return }
          mapView.addAnnotations([p1, p2])
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
            return renderer
        }
    }
}
