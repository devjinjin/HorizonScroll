//
//  CarouselAlertViewController.swift
//  SwipeViewPager
//
//  Created by jylee-mac on 2021/05/21.
//

import UIKit

class CarouselAlertViewController: UIViewController {

    var item : CarouselItem?
    
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var dimmerView: UIView!
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var itemDetailDescription: UILabel!
    @IBOutlet weak var roundView: RounedCornerView!
    override func viewDidLoad() {
        super.viewDidLoad()

        itemTitle.text = item?.title
        
        // dimmerViewTapped() 제스처 추가
        let dimmerTap = UITapGestureRecognizer(target: self, action: #selector(dimmerViewTapped(_:)))
        dimmerView.addGestureRecognizer(dimmerTap)
        dimmerView.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }
    @IBAction func dimmerViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        if(self.presentingViewController != nil) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
