import Photos
import Vision
import UIKit

final class PhotoDetailsViewModel {

    private let saliencyProcessingQueue = DispatchQueue(
        label: "Queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem
    )

    private let imageManager: PHImageManager
    let photoAsset: PHAsset

    init(photoAsset: PHAsset, imageManager: PHImageManager = PHImageManager.default()) {
        self.photoAsset = photoAsset
        self.imageManager = imageManager
    }

    func imageForSize(_ size: CGSize, completion: PhotoFetchCompletionHandler?) {
        imageManager.imageForSize(size, photoAsset: photoAsset, completion: completion)
    }

    /// Saliency Observation
    func processSaliency(in image: UIImage, completion: SaliencyProcessCompletionHandler?) {
        let saliencyRequest = VNGenerateAttentionBasedSaliencyImageRequest(completionHandler: nil)

        saliencyProcessingQueue.async { [weak self] in
            guard let self = self, let cgImage = image.cgImage else { return }
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([saliencyRequest])
                guard
                    let lastResult = saliencyRequest.results?.last,
                    let observation = lastResult.salientObjects?.last
                else {
                    completion?(nil, Constant.saliencyProcessingError)
                    return
                }
                let finalImage = self.drawBox(onImage: image, atObservation: observation)

                DispatchQueue.main.async {
                    completion?(finalImage, nil)
                }
            } catch(let error) {
                DispatchQueue.main.async { completion?(nil, error) }
            }
        }
    }

    func drawBox(onImage image: UIImage, atObservation observation: VNRectangleObservation) -> UIImage? {

        /// Scaling Vision coordinates to image size
        var bottomLeft = observation.topLeft.scaled(to: image.size)
        var bottomRight = observation.topRight.scaled(to: image.size)
        var topLeft = observation.bottomLeft.scaled(to: image.size)
        var topRight = observation.bottomRight.scaled(to: image.size)
        
        /// Since Vision coordinates have top equals to bottom of normal UIKit drawing, following adjustment is done to reflect box correctly on UIKit coords
        let newTopLeftY = image.size.height - (bottomLeft.y)
        let newBottomLeftY = image.size.height - topLeft.y

        topLeft.y = newTopLeftY
        bottomLeft.y = newBottomLeftY
        topRight.y = topLeft.y
        bottomRight.y = bottomLeft.y

        /// Drawing Box on image
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: .zero)
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(Constant.saliencyObjectBoundingLineWidth)
        context?.setStrokeColor(Constant.saliencyObjectBoundingBoxColor)
        context?.move(to: topLeft)
        context?.addLine(to: topRight)
        context?.addLine(to: bottomRight)
        context?.addLine(to: bottomLeft)
        context?.addLine(to: topLeft)
        context?.strokePath()
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
}

/// Constants
extension PhotoDetailsViewModel {
    
    private enum Constant {
        static let saliencyProcessingError = NSError(domain: "SaliencyProcessing", code: 605, userInfo: nil) as Error
        static let saliencyObjectBoundingBoxColor = UIColor.red.cgColor
        static let saliencyObjectBoundingLineWidth: CGFloat = 3.0
    }
}
