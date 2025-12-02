import UIKit
import IGolfViewer3D

class ViewController: UIViewController {

    @IBOutlet weak var renderView: CourseRenderView!
    
    private var isRenderViewLoaded = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        loadGolfCourse()
    }
    
    
    private func loadGolfCourse() {
        
        guard !isRenderViewLoaded else {
            return
        }
        
        isRenderViewLoaded = true
        
        let loader = CourseRenderViewLoader(
            applicationAPIKey: "gAil-pspH8q4PgM",
            applicationSecretKey: "CgkDhdiAZoocUWf135VlKc4BGd2xrq",
            idCourse: "fAwbKaonIp7Q")
        
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        
        loader.setLoading(activityIndicatorView)
        loader.initialNavigationMode = .modeOverallHole
        
        renderView.load(with: loader)
        
        activityIndicatorView.startAnimating()
    }
}
