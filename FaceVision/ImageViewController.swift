//
//  ImageViewController.swift
//  FaceVision
//
//  Created by Tony Low on 16/02/2018.
//  Copyright © 2017 Gotcha Studio. All rights reserved.
//

import UIKit
import Vision

@available(iOS 11.0, *)
class ImageViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var browsDesc: UILabel!
    @IBOutlet weak var noseDesc: UILabel!
    @IBOutlet weak var faceDesc: UILabel!
    @IBOutlet weak var lipsDesc: UILabel!
    @IBOutlet weak var eyesDesc: UILabel!
    
    @IBOutlet weak var hashtag1: UILabel!
    @IBOutlet weak var hashtag2: UILabel!
    @IBOutlet weak var hashtag3: UILabel!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    @IBOutlet weak var savelbl: UILabel!
    @IBOutlet weak var sharelbl: UILabel!
    @IBOutlet weak var backlbl: UILabel!
    
    @IBOutlet weak var bg1: UIImageView!
    @IBOutlet weak var bg2: UIImageView!
    @IBOutlet weak var bg3: UIImageView!
    @IBOutlet weak var errorMsg: UILabel!
    
    var image: UIImage!
    var data: String!
    var csvRows: [[String]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        imageView.image = image
        
        data = readDataFromCSV(fileName: "data", fileType: "csv")
        data = cleanRows(file: data)
        csvRows = csv(data: data)
        
        process()
        
    }

    @IBAction func sharePhoto(_ sender: UIButton) {
        let finalImage:UIImage = captureScreen()!
        
        InstagramHelper.sharedManager.postImageToInstagramWithCaption(imageInstagram: finalImage, instagramCaption: (hashtag1.text!+hashtag2.text!+hashtag3.text!),controller: self)
    }
    
    @IBAction func savePhoto(_ sender: UIButton) {
        let finalImage:UIImage = captureScreen()!
        let photoAlbum = YourFacePhotoAlbum()
        photoAlbum.save(image: finalImage)
        let alert = UIAlertController(title: "Saved", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func process() {
        var orientation:Int32 = 0
        
        // detect image orientation, we need it to be accurate for the face detection to work
        switch image.imageOrientation {
        case .up:
            orientation = 1
        case .right:
            orientation = 6
        case .down:
            orientation = 3
        case .left:
            orientation = 8
        default:
            orientation = 1
        }
        
        // vision
        let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: self.handleFaceFeatures)
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, orientation: CGImagePropertyOrientation(rawValue: UInt32(orientation))! ,options: [:])
        do {
            try requestHandler.perform([faceLandmarksRequest])
        } catch {
            print(error)
        }
    }
    
    func handleFaceFeatures(request: VNRequest, errror: Error?) {
        guard let observations = request.results as? [VNFaceObservation] else {
            fatalError("unexpected result type!")
        }
        
        print(observations.count)
        
        if (observations.count != 1){
            hideAllDesc()
            return
        }
        else{
            for face in observations {
                addFaceLandmarksToImage(face)
            }
        }
    }
    
    func addFaceLandmarksToImage(_ face: VNFaceObservation) {
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        // draw the image
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        // draw the face rect
        let w = face.boundingBox.size.width * image.size.width
        let h = face.boundingBox.size.height * image.size.height
        let x = face.boundingBox.origin.x * image.size.width
        let y = face.boundingBox.origin.y * image.size.height
        
        var browShape:String = ""
        var faceShape:String = ""
        var eyeShape:String = ""
        var lipSize:String = ""
        var noseSize:String = ""
        
        var areaFace:Double = 0.0
        var lengthFace:Double = 0.0
        var heightFace:Double = 0.0
        var gradientFace:Double = 0.0
        
        var areaOutterLips:Double = 0.0
        var heightOutterLips:Double = 0.0
        var areaInnerLips:Double = 0.0
        var heightInnerLips:Double = 0.0
        
        var areaLeftEye:Double = 0.0
        var areaRightEye:Double = 0.0
        
        var leftEyeLength: Double = 0.0
        var rightEyeLength: Double = 0.0
        
        var areaLeftEyebrow:Double = 0.0
        var lengthLeftEyebrow:Double = 0.0
        
        var areaRightEyebrow:Double = 0.0
        var lengthRightEyebrow:Double = 0.0
        
        var areaNose:Double = 0.0
        
        // face contour
        if let landmark = face.landmarks?.faceContour {
            for i in 0...landmark.pointCount - 1 { // last point is 0,0
                let point = landmark.normalizedPoints[i]
                if i == 0 {
                    context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
                } else {
                    context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
                }
            }
            areaFace = abs(polygonArea(landmark: landmark)*10000)
            lengthFace = faceDistance(landmark: landmark)
            heightFace = landmarkHeight(landmark: landmark)
            gradientFace = faceGradient(landmark: landmark)
            
        }
        
        
        
        // outer lips
        if let landmark = face.landmarks?.outerLips {
            for i in 0...landmark.pointCount - 1 { // last point is 0,0
                let point = landmark.normalizedPoints[i]
                if i == 0 {
                    context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
                } else {
                    context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
                }
            }
            areaOutterLips = abs(polygonArea(landmark: landmark)*10000)
            heightOutterLips = landmarkHeight(landmark: landmark)
        }
        
        // inner lips
        if let landmark = face.landmarks?.innerLips {
            for i in 0...landmark.pointCount - 1 { // last point is 0,0
                let point = landmark.normalizedPoints[i]
                if i == 0 {
                    context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
                } else {
                    context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
                }
            }
            areaInnerLips = abs(polygonArea(landmark: landmark)*10000)
            heightInnerLips = landmarkHeight(landmark: landmark)
        }
        
        // left eye
        if let landmark = face.landmarks?.leftEye {
            for i in 0...landmark.pointCount - 1 { // last point is 0,0
                let point = landmark.normalizedPoints[i]
                if i == 0 {
                    context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
                } else {
                    context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
                }
            }
            areaLeftEye = abs(polygonArea(landmark: landmark)*10000)
            leftEyeLength = landmarkWidth(landmark: landmark)
        }
        
        
        // right eye
        if let landmark = face.landmarks?.rightEye {
            for i in 0...landmark.pointCount - 1 { // last point is 0,0
                let point = landmark.normalizedPoints[i]
                if i == 0 {
                    context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
                } else {
                    context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
                }
            }
            areaRightEye = abs(polygonArea(landmark: landmark)*10000)
            rightEyeLength = landmarkWidth(landmark: landmark)
        }
        
        // left eyebrow
        if let landmark = face.landmarks?.leftEyebrow {
            for i in 0...landmark.pointCount - 1 { // last point is 0,0
                let point = landmark.normalizedPoints[i]
                if i == 0 {
                    context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
                } else {
                    context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
                }
            }
            areaLeftEyebrow = abs(polygonArea(landmark: landmark)*10000)
            lengthLeftEyebrow = eyebrowDistance(landmark: landmark)
        }
        
        // right eyebrow
        if let landmark = face.landmarks?.rightEyebrow {
            for i in 0...landmark.pointCount - 1 { // last point is 0,0
                let point = landmark.normalizedPoints[i]
                if i == 0 {
                    context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
                } else {
                    context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
                }
            }
            areaRightEyebrow = abs(polygonArea(landmark: landmark)*10000)
            lengthRightEyebrow = eyebrowDistance(landmark: landmark)
        }
        
        // nose
        if let landmark = face.landmarks?.nose {
            for i in 0...landmark.pointCount - 1 { // last point is 0,0
                let point = landmark.normalizedPoints[i]
                if i == 0 {
                    context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
                } else {
                    context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
                }
            }
            areaNose = abs(polygonArea(landmark: landmark)*10000)
        }
        
        let areaEyeBrows:Double = areaLeftEyebrow + areaRightEyebrow
        let lengthEyeBrows:Double = lengthLeftEyebrow + lengthRightEyebrow
        let areaEyes:Double = areaLeftEye + areaRightEye
        let lengthEyes:Double = leftEyeLength + rightEyeLength
        
        let browThicknessIndicator:Double = areaEyeBrows/lengthEyeBrows
        let browLengthIndicator:Double = lengthEyeBrows/2*1000/areaFace
        let faceShapeIndicator:Double = abs(gradientFace)
        let eyeSizeIndicator:Double = areaEyes/2/areaFace
        let eyeLengthIndicator:Double = lengthEyes/lengthFace
        let lipSizeIndicator:Double = (areaOutterLips-areaInnerLips)/areaFace
        let lipHeightIndicator:Double = (heightOutterLips-heightInnerLips)/heightFace
        let noseSizeIndicator:Double = areaNose/areaFace
        
        let browDiff1:Double = abs(browThicknessIndicator-230)/230
        let browDiff2:Double = abs(browLengthIndicator-0.051)/0.051
        let eyeDiff1:Double = abs(eyeSizeIndicator-0.14)/0.14
        let eyeDiff2:Double = abs(eyeLengthIndicator-0.4)/0.4
        let lipDiff1:Double = abs(lipSizeIndicator-0.05)/0.05
        let lipDiff2:Double = abs(lipHeightIndicator-0.148)/0.148
        
        print(browThicknessIndicator)
        print(browLengthIndicator)
        print(faceShapeIndicator)
        print(eyeSizeIndicator)
        print(eyeLengthIndicator)
        print(lipSizeIndicator)
        print(lipHeightIndicator)
        print(noseSizeIndicator)
        
        let strokeTextAttributes = [
            NSAttributedStringKey.strokeColor : UIColor.black,
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.strokeWidth : -3.0,
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 20)
            ] as [NSAttributedStringKey : Any]
        
        if (browDiff1 > browDiff2){
            if (browThicknessIndicator > 230){
                browShape = "thick"
                browsDesc.attributedText = NSMutableAttributedString(string: "眉毛粗，好襟撈", attributes: strokeTextAttributes)
            }
            else{
                browShape = "thin"
                browsDesc.text = "眉毛幼，食肉獸"
                browsDesc.attributedText = NSMutableAttributedString(string: "眉毛幼，食肉獸", attributes: strokeTextAttributes)
            }
        }
        else{
            if (browLengthIndicator > 0.051){
                browShape = "long"
                browsDesc.text = "眉毛長，夠大量"
                browsDesc.attributedText = NSMutableAttributedString(string: "眉毛長，夠大量", attributes: strokeTextAttributes)
            }
            else{
                browShape = "short"
                browsDesc.text = "眉毛短，易跌損"
                browsDesc.attributedText = NSMutableAttributedString(string: "眉毛短，易跌損", attributes: strokeTextAttributes)
            }
        }
        
        if (faceShapeIndicator > 0.3){
            faceShape = "square"
            faceDesc.attributedText = NSMutableAttributedString(string: "面方方，等人劏", attributes: strokeTextAttributes)
        }
        else if (faceShapeIndicator <= 0.3 && faceShapeIndicator > 0.2){
            faceShape = "round"
            faceDesc.attributedText = NSMutableAttributedString(string: "面圓圓，好溫柔", attributes: strokeTextAttributes)
        }
        else{
            faceShape = "sharp"
            faceDesc.attributedText = NSMutableAttributedString(string: "面尖尖，好奄尖", attributes: strokeTextAttributes)
        }
        
        if (eyeDiff1 > eyeDiff2){
            if (eyeSizeIndicator > 0.014){
                eyeShape = "big"
                eyesDesc.attributedText = NSMutableAttributedString(string: "眼大大，心地壞", attributes: strokeTextAttributes)
            }
            else{
                eyeShape = "small"
                eyesDesc.attributedText = NSMutableAttributedString(string: "眼細細，多詭計", attributes: strokeTextAttributes)
            }
        }
        else{
            if (eyeLengthIndicator > 0.4){
                eyeShape = "long"
                eyesDesc.attributedText = NSMutableAttributedString(string: "眼長長，好淒涼", attributes: strokeTextAttributes)
            }
            else{
                eyeShape = "short"
                eyesDesc.attributedText = NSMutableAttributedString(string: "眼圓圓，易沉船", attributes: strokeTextAttributes)
            }
        }
        
        if (lipDiff1 > lipDiff2){
            if (lipSizeIndicator > 0.05){
                lipSize = "big"
                lipsDesc.attributedText = NSMutableAttributedString(string: "嘴唇厚，生花柳", attributes: strokeTextAttributes)
            }
            else{
                lipSize = "small"
                lipsDesc.attributedText = NSMutableAttributedString(string: "嘴唇厚，生花柳", attributes: strokeTextAttributes)
            }
        }
        else{
            if (lipHeightIndicator > 0.148){
                lipSize = "thick"
                lipsDesc.attributedText = NSMutableAttributedString(string: "嘴唇厚，生花柳", attributes: strokeTextAttributes)
            }
            else{
                lipSize = "thin"
                lipsDesc.attributedText = NSMutableAttributedString(string: "嘴唇薄，好刻薄", attributes: strokeTextAttributes)
            }
        }
        
        if (noseSizeIndicator > 0.08){
            noseSize = "big"
            noseDesc.attributedText = NSMutableAttributedString(string: "鼻哥大大，\n堅持不懈", attributes: strokeTextAttributes)
        }
        else{
            noseSize = "small"
            noseDesc.attributedText = NSMutableAttributedString(string: "鼻哥細細，\n成日破費", attributes: strokeTextAttributes)
        }
        
        print(browShape)
        print(faceShape)
        print(eyeShape)
        print(lipSize)
        print(noseSize)
        
        for csvRow in csvRows {
            if (csvRow[1] == browShape && csvRow[2] == eyeShape && csvRow[3] == noseSize && csvRow[4] == lipSize && csvRow[5] == faceShape){
                self.hashtag1.text = "#" + csvRow[6]
                self.hashtag2.text = "#" + csvRow[7]
                self.hashtag3.text = "#" + csvRow[8]
            }
        }
        
        // get the final image
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // end drawing context
        UIGraphicsEndImageContext()
        
        imageView.image = finalImage
    }
    
    func polygonArea(landmark: VNFaceLandmarkRegion2D) -> Double {
        var area:Double = 0.0
        var j = landmark.pointCount - 1
        for i in 0...landmark.pointCount - 1 {
            let point1 = landmark.normalizedPoints[i]
            let point2 = landmark.normalizedPoints[j]
            area = area + Double(( CGFloat(point2.x) + CGFloat(point1.x)) * (CGFloat(point2.y) - CGFloat(point1.y) ))
            j=i
        }
        return area * 0.5
    }
    
    func eyebrowDistance(landmark: VNFaceLandmarkRegion2D) -> Double {
        var distance:Double = 0.0
        for i in 0...landmark.pointCount - 2 {
            let point1 = landmark.normalizedPoints[i]
            let point2 = landmark.normalizedPoints[i+1]
            distance = distance + Double(hypotf(Float(point1.x) - Float(point2.x), Float(point1.y) - Float(point2.y)));
        }
        return distance
    }
    
    func faceDistance(landmark: VNFaceLandmarkRegion2D) -> Double {
        var distance:Double = 0.0
        let point1 = landmark.normalizedPoints[0]
        let point2 = landmark.normalizedPoints[landmark.pointCount-1]
        distance = Double(hypotf(Float(point1.x) - Float(point2.x), Float(point1.y) - Float(point2.y)));
        return distance
    }
    
    func faceGradient(landmark: VNFaceLandmarkRegion2D) -> Double {
        var gradient:Double = 0.0
        let point1 = landmark.normalizedPoints[0]
        let point2 = landmark.normalizedPoints[3]
        gradient = Double((Float(point1.x) - Float(point2.x))/(Float(point1.y) - Float(point2.y)));
        return gradient
    }
    
    func landmarkWidth(landmark: VNFaceLandmarkRegion2D) -> Double {
        var width:Double = 0.0
        var max:CGFloat = landmark.normalizedPoints[0].x
        var min:CGFloat = landmark.normalizedPoints[0].x
        for i in 1...landmark.pointCount - 1 {
            let ptX = landmark.normalizedPoints[i].x
            if (ptX > max) {
                max = ptX
            }
            if (ptX < min) {
                min = ptX
            }
        }
        width = Double(Double(max) - Double(min))
        return width
    }
    
    func landmarkHeight(landmark: VNFaceLandmarkRegion2D) -> Double {
        var height:Double = 0.0
        var max:CGFloat = landmark.normalizedPoints[0].y
        var min:CGFloat = landmark.normalizedPoints[0].y
        for i in 1...landmark.pointCount - 1 {
            let ptY = landmark.normalizedPoints[i].y
            if (ptY > max) {
                max = ptY
            }
            if (ptY < min) {
                min = ptY
            }
        }
        height = Double(Double(max) - Double(min))
        return height
    }
    
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    
    func readDataFromCSV(fileName:String, fileType: String)-> String!{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
            else {
                return nil
        }
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
    
    
    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        //        cleanFile = cleanFile.replacingOccurrences(of: ";;", with: "")
        //        cleanFile = cleanFile.replacingOccurrences(of: ";\n", with: "")
        return cleanFile
    }
    
    func captureScreen() -> UIImage? {
        backBtn.isHidden = true
        saveBtn.isHidden = true
        shareBtn.isHidden = true
        backlbl.isHidden = true
        savelbl.isHidden = true
        sharelbl.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.bounds.size)
        self.view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        backBtn.isHidden = false
        saveBtn.isHidden = false
        shareBtn.isHidden = false
        backlbl.isHidden = false
        savelbl.isHidden = false
        sharelbl.isHidden = false
        return image
    }
    
    func hideAllDesc(){
        let strokeTextAttributes = [
            NSAttributedStringKey.strokeColor : UIColor.black,
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.strokeWidth : -3.0,
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 30)
            ] as [NSAttributedStringKey : Any]
        
        errorMsg.isHidden = false
        errorMsg.attributedText = NSMutableAttributedString(string: "Face detection failed: please move the target face closer and aim at the center of the screen", attributes: strokeTextAttributes)
        
        self.image = nil
        browsDesc.isHidden = true
        eyesDesc.isHidden = true
        noseDesc.isHidden = true
        faceDesc.isHidden = true
        lipsDesc.isHidden = true
        bg1.isHidden = true
        bg2.isHidden = true
        bg3.isHidden = true
        saveBtn.isHidden = true
        shareBtn.isHidden = true
        sharelbl.isHidden = true
        savelbl.isHidden = true
    }
}


