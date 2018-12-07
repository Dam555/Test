//
//  ViewController.swift
//  Test
//
//  Created by Damjan on 07/12/2018.
//  Copyright © 2018 Genesis Mobile. All rights reserved.
//

import UIKit

class MainController: UIViewController {

    /// Views and layout constraints.
    @IBOutlet var scrollView: UIScrollView!

    @IBOutlet var triangleSidesScrollView: UIScrollView!
    @IBOutlet var triangleSideATextField: UITextField!
    @IBOutlet var triangleSideBTextField: UITextField!
    @IBOutlet var triangleSideCTextField: UITextField!
    
    @IBOutlet var trianglesTableView: UITableView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    /// Detail controller segue identifier.
    let detailControllerSegueIdentifier = "detailControllerSegue"
    
    /// Calculated triangle surface.
    var calculatedTriangleSurface: Double = 0.0
    
    /// All triangles for which surface has been calculated.
    var triangles = [Triangle]()
    
    /// Reusable cell identifier for triangles table view cell.
    let trianglesTableViewReusableCellIdentifier = "tableViewCell"
    
    /// Number formatter.
    var numberFormatter: NumberFormatter!
    
    /// Date formatter.
    var dateFormatter: DateFormatter!

    /// View did load.
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        
        triangleSidesScrollView.contentInsetAdjustmentBehavior = .never
        
        trianglesTableView.cellLayoutMarginsFollowReadableWidth = false
        trianglesTableView.layoutMargins = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
        trianglesTableView.dataSource = self
        trianglesTableView.delegate = self
        trianglesTableView.rowHeight = 140.0
        trianglesTableView.register(UITableViewCell.self, forCellReuseIdentifier: trianglesTableViewReusableCellIdentifier)
        
        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.4)
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0
        
        numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name:   UIResponder.keyboardWillHideNotification, object: nil)
    }

    /// Whether status bar is hidden.
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /// View will transition to different size.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.scrollView.delegate = nil
        coordinator.animate(alongsideTransition: { (context) in
            self.scrollView.setContentOffset(CGPoint(x: size.width * CGFloat(self.pageControl.currentPage), y: self.scrollView.contentOffset.y), animated: false)
            self.trianglesTableView.reloadData()
        }) { (context) in
            self.scrollView.delegate = self
        }
    }
    
    /// Keyboard will show.
    @objc func keyboardWillShow(_ notification: Notification) {
        let keyboardHeight = ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.size.height ?? 0.0)
        
        var contentInset = triangleSidesScrollView.contentInset
        contentInset.bottom = keyboardHeight
        triangleSidesScrollView.contentInset = contentInset
        triangleSidesScrollView.scrollIndicatorInsets = contentInset
    }
    
    /// Keyboard will hide.
    @objc func keyboardWillHide(_ notification: Notification) {
        var contentInset = triangleSidesScrollView.contentInset
        contentInset.bottom = 0.0
        triangleSidesScrollView.contentInset = contentInset
        triangleSidesScrollView.scrollIndicatorInsets = contentInset
    }

    /// Page control's current page has changed.
    @IBAction func pageControlDidChange(_ sender: UIPageControl) {
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.size.width * CGFloat(pageControl.currentPage), y: 0.0), animated: true)
    }
    
    /// Presents alert controller with title and dismiss button.
    func presentAlertController(with title: String) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
    
    /// Calculate surface button did touch up inside.
    @IBAction func calculateSurfaceButtonDidTouchUpInside(_ sender: UIButton) {
        var sideA: Double?
        var sideB: Double?
        var sideC: Double?
        
        if let sideAText = triangleSideATextField.text, let aSideA = Double(sideAText), !sideAText.isEmpty {
            sideA = aSideA
        } else {
            presentAlertController(with: "Please enter valid triangle side A")
        }
        if let sideBText = triangleSideBTextField.text, let aSideB = Double(sideBText), !sideBText.isEmpty {
            sideB = aSideB
        } else {
            presentAlertController(with: "Please enter valid triangle side B")
        }
        if let sideCText = triangleSideCTextField.text, let aSideC = Double(sideCText), !sideCText.isEmpty {
            sideC = aSideC
        } else {
            presentAlertController(with: "Please enter valid triangle side C")
        }

        if let sideA = sideA, let sideB = sideB, let sideC = sideC {
            let triangle = Triangle(sideA: sideA, sideB: sideB, sideC: sideC)
            
            if triangle.surface.isNaN {
                presentAlertController(with: "Please enter valid triangle sides A, B and C so surface can be calculated")
            } else {
                triangles.append(triangle)
                triangles.sort() { $0.surface > $1.surface }
                trianglesTableView.reloadData()

                calculatedTriangleSurface = triangle.surface
                performSegue(withIdentifier: detailControllerSegueIdentifier, sender: self)
            }
        }
    }

    /// Prepare segue's destination view controller.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailController = (segue.destination as? UINavigationController)?.viewControllers.first as? DetailController, segue.identifier == detailControllerSegueIdentifier {
            detailController.triangleSurface = calculatedTriangleSurface
        }
    }
}

extension MainController: UIScrollViewDelegate {
    
    /// Scroll view did scroll.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        /// Update page control's current page.
        if scrollView === self.scrollView {
            let page = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
            pageControl.currentPage = page
        }
    }
}

extension MainController: UITableViewDataSource {
    
    /// Number of sections in triangles table view.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// Number of rows in triangles table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return triangles.count
    }
    
    /// Triangles table view cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: trianglesTableViewReusableCellIdentifier) {
            let triangle = triangles[indexPath.row]
            
            let text = "Side A: \(numberFormatter.string(from: NSNumber(value: triangle.sideA)) ?? "")\nSide B: \(numberFormatter.string(from: NSNumber(value: triangle.sideB)) ?? "")\nSide C: \(numberFormatter.string(from: NSNumber(value: triangle.sideC)) ?? "")\nSurface: \(numberFormatter.string(from: NSNumber(value: triangle.surface)) ?? "")\nDate: \(dateFormatter.string(from: triangle.date))"
            
            let style = NSMutableParagraphStyle()
            style.alignment = .left
            style.firstLineHeadIndent = view.safeAreaInsets.left
            style.headIndent = view.safeAreaInsets.left
            
            cell.textLabel?.attributedText = NSAttributedString(string: text, attributes: [.paragraphStyle: style])
            cell.textLabel?.numberOfLines = 0
            
            return cell
        }
        return UITableViewCell(frame: CGRect.zero)
    }
}

extension MainController: UITableViewDelegate {

    /// Whether row in triangles table view should be highlighted.
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
