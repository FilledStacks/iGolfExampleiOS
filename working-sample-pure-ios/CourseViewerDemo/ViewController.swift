import UIKit
import IGolfViewer3D

class ViewController: UIViewController {

    @IBOutlet weak var renderView: CourseRenderView!
    
    private var isLoaded: Bool = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        if !isLoaded {
            loadGolfCourse()
        }
    }
    
    
    private func loadGolfCourse() {
        
        isLoaded = true
        
        let loadingView = UIActivityIndicatorView(style: .large)
        loadingView.color = .orange
        loadingView.startAnimating();
        
        let loader = CourseRenderViewLoader.init(
            applicationAPIKey: "gAil-pspH8q4PgM",
            applicationSecretKey: "CgkDhdiAZoocUWf135VlKc4BGd2xrq",
            idCourse: "fAwbKaonIp7Q")
        
 
        loader.measurementSystem = .metric
        loader.showCalloutOverlay = false
        loader.drawCentralPathMarkers = false
        loader.drawDogLegMarker = true
        loader.areFrontBackMarkersDynamic = true
        loader.rotateHoleOnLocationChanged = true
        loader.autoAdvanceActive = true
        loader.draw3DCentralLine = false
        loader.setLoading(loadingView)
        loader.initialNavigationMode = .modeFreeCam
        loader.preload(completionHandler: { [weak self] in
            self?.renderView.load(with: loader)
        }, errorHandler: { [weak self] (error) in
        
        })
    }
}
