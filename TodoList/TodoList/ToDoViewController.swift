//
//  ToDoViewController.swift
//  TodoList
//
//  Created by VuVince on 9/13/16.
//  Copyright © 2016 VuVince. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON



class ToDoViewController: UIViewController {

    @IBOutlet weak var btnAddItem: UIBarButtonItem!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //current tab
    
    let pendingVC = UITableViewController()
    let doneVC = UITableViewController()
    var pendingDataSource :ListDataSource!
    var doneDataSource :ListDataSource!
    var pageVC :UIPageViewController!
    
    
    let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        indicator.color = UIColor.darkGrayColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PageViewController" {
            pageVC = segue.destinationViewController as! UIPageViewController
            pageVC.dataSource = self
            pageVC.setViewControllers([pendingVC], direction: .Forward, animated: false, completion: nil)
            getModels()
            
            doneDataSource = ListDataSource(tableView: doneVC.tableView, delegate: self, type: ListType.Done)
            pendingDataSource = ListDataSource(tableView: pendingVC.tableView, delegate: self, type: ListType.Pending)
            
            for view in pageVC.view.subviews {
                if view.isKindOfClass(UIScrollView.self) {
                    let scrollView = view as! UIScrollView
                    scrollView.scrollEnabled = false
                    
                }
            }
        }
    }

    @IBAction func btnAddItemClicked(sender: AnyObject) {
        addPendingItem()
    }
    
    
    @IBAction func segmentedControlClicked(sender: AnyObject) {
        if segmentedControl.selectedSegmentIndex == 0 {
            self.pageVC.setViewControllers([pendingVC], direction: .Reverse, animated: false, completion: nil)
            
            self.btnAddItem.enabled = true
            btnAddItem.customView?.alpha = 1
            segmentedControl.selectedSegmentIndex = 0
        } else {
            self.pageVC.setViewControllers([doneVC], direction: .Forward, animated: false, completion: nil)
            self.btnAddItem.enabled = false
            btnAddItem.customView?.alpha = 0
            segmentedControl.selectedSegmentIndex = 1
        }
    }
    
    
}


//MARK: - Save, Update models
extension ToDoViewController {
    
    func getModels() {
        indicator.startAnimating()
        
        CustomService.getData({ (data) in
            for item in data {
                let dict = item.dictionaryValue
                let todoModel =  VTDataManager.defaultManager.insertOrUpdatetodoModel(withID: dict["id"]?.int)
                todoModel.id = dict["id"]?.int
                todoModel.name = dict["name"]?.string
                todoModel.state = dict["state"]?.int
                
                self.indicator.stopAnimating()
            }
        }) { (error) in
            self.indicator.stopAnimating()
        }
    }
    
    func addPendingItem() {
        let alertController = UIAlertController(title: "Add New Todo", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            let id = Int(NSDate().timeIntervalSince1970)
            let model = VTDataManager.defaultManager.insertOrUpdatetodoModel(withID: id)
            model.name = firstTextField.text
            model.state = NSNumber(integer: ListType.Pending.rawValue)
            model.id = id
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Todo Name"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}

//MARK: UIPageViewControllerDataSource
extension ToDoViewController:UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if viewController == pendingVC {
            return doneVC
        } else {
            return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if viewController == doneVC {
            return pendingVC
        } else {
            return nil
        }
    }
}



//MARK: ListDataSourceDelegate
extension ToDoViewController: ListDataSourceDelegate {
    
}
