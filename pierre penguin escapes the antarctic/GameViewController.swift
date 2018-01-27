import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
    var musicPlayer = AVAudioPlayer()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Build the menu scene
        let menuScene = MenuScene()
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true // Ignore drawing order of child nodes // (This increases performance)
        menuScene.size = view.bounds.size // Size our scene to fit the view exactly
        skView.presentScene(menuScene)
        
        guard let musicPath = Bundle.main.path(forResource: "Sound/BackgroundMusic.m4a", ofType: nil) else { return }
        let url = URL(fileURLWithPath: musicPath)
        
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer.numberOfLoops = -1
            musicPlayer.prepareToPlay()
            musicPlayer.play()
        }
        catch {
            let alertViewController = UIAlertController(title: "Missing Resource", message: "Cannot find resource for audio", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertViewController.addAction(okAction)
            self.present(alertViewController, animated: true, completion: nil)
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}





