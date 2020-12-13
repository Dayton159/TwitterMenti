//
//  ViewController.swift
//  TwitterMenti
//
//  Created by Dayton on 13/12/20.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON


class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let tweetCount = 100
    let sentimentClassifier:TweetSentimentClassifier  = try! TweetSentimentClassifier(configuration:  MLModelConfiguration.init())
    // use swifter to init new instance of the framework and will authenticate us using this API key & API secret
    let swifter = Swifter(consumerKey: "gW69r9sCdyLTI2wE8gxLSIf6i", consumerSecret: "t1AYpYu1hGrszuZ7p4ybHnDkhcKc2ZdCHQ8jOW0isINa2Mrsll")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        
        fetchTweets()
        
    }
    func fetchTweets(){
        
        if let searchText = textField.text {
            
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount , tweetMode: .extended ,success: { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                
                for i in 0..<self.tweetCount {
                    
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                        print(tweet)
                    }
                }
                self.makePrediction(with: tweets)
                
            }) { (error) in
                print("There was an error with the Twitter API Request \(error)")
            }
        }
    }
    
    func makePrediction(with tweets: [TweetSentimentClassifierInput]){
        do{
            let predictions =  try self.sentimentClassifier.predictions(inputs: tweets)
            
            
            var sentimentScore = 0
            
            for prediction in predictions {
                let sentiment = prediction.label
                
                if sentiment ==  "Pos" {
                    sentimentScore += 1
                }else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
            }
            print(sentimentScore)
            updateUI(with: sentimentScore)
            
        }catch {
            print("There was an error making the prediction \(error)")
        }
        
        
    }
    
    func updateUI(with sentimentScore:Int){
    
        if sentimentScore  > 20 {
            self.sentimentLabel.text = "😍"
        }else if sentimentScore > 10 {
            self.sentimentLabel.text = "😀"
        } else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
        }else if sentimentScore == 0 {
            self.sentimentLabel.text = "😐"
        }else if sentimentScore > -10 {
            self.sentimentLabel.text = "😕"
        }else if sentimentScore > -20 {
            self.sentimentLabel.text = "😡"
        }else  {
            self.sentimentLabel.text = "🤮"
        }
        
    }
    
}

