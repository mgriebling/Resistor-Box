//
//  ResistorImage.swift
//  ResistorBox
//
//  Created by Mike Griebling on 8 Mar 2018.
//  Copyright © 2018 Computer Inspirations. All rights reserved.
//
//  Generated by PaintCode
//  http://www.paintcodeapp.com
//



import UIKit

public class ResistorImage : NSObject {

    //// Drawing Methods

    @objc dynamic public class func drawResistor(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 153, height: 55), resizing: ResizingBehavior = .aspectFit, resistorValue: String = "Open") {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 153, height: 55), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 153, y: resizedFrame.height / 55)


        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 2, y: 37))
        bezierPath.addCurve(to: CGPoint(x: 26, y: 37), controlPoint1: CGPoint(x: 26, y: 37), controlPoint2: CGPoint(x: 26, y: 37))
        bezierPath.addLine(to: CGPoint(x: 37, y: 21))
        bezierPath.addLine(to: CGPoint(x: 54, y: 53))
        bezierPath.addLine(to: CGPoint(x: 70, y: 21))
        bezierPath.addLine(to: CGPoint(x: 86, y: 53))
        bezierPath.addLine(to: CGPoint(x: 103, y: 21))
        bezierPath.addCurve(to: CGPoint(x: 119, y: 53), controlPoint1: CGPoint(x: 103, y: 21), controlPoint2: CGPoint(x: 119, y: 55))
        bezierPath.addCurve(to: CGPoint(x: 127, y: 37), controlPoint1: CGPoint(x: 119, y: 51), controlPoint2: CGPoint(x: 127, y: 37))
        bezierPath.addLine(to: CGPoint(x: 151, y: 37))
        UIColor.black.setStroke()
        bezierPath.lineWidth = 3
        bezierPath.lineCapStyle = .round
        bezierPath.lineJoinStyle = .round
        bezierPath.stroke()


        //// Text Drawing
        let textRect = CGRect(x: 25, y: -5, width: 103, height: 27)
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        let textFontAttributes = [
            .font: UIFont(name: "HelveticaNeue-Bold", size: 20)!,
            .foregroundColor: UIColor.black,
            .paragraphStyle: textStyle,
        ] as [NSAttributedStringKey: Any]

        let textTextHeight: CGFloat = resistorValue.boundingRect(with: CGSize(width: textRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: textFontAttributes, context: nil).height
        context.saveGState()
        context.clip(to: textRect)
        resistorValue.draw(in: CGRect(x: textRect.minX, y: textRect.minY + (textRect.height - textTextHeight) / 2, width: textRect.width, height: textTextHeight), withAttributes: textFontAttributes)
        context.restoreGState()
        
        context.restoreGState()

    }

    @objc dynamic public class func drawSeriesResistors(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 466, height: 80), resizing: ResizingBehavior = .aspectFit, value1: String = "11.1K", value2: String = "22.2K", value3: String = "33.3K") {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 466, height: 80), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 466, y: resizedFrame.height / 80)


        //// Symbol Drawing
        let symbolRect = CGRect(x: 8, y: 6, width: 153, height: 55)
        context.saveGState()
        context.clip(to: symbolRect)
        context.translateBy(x: symbolRect.minX, y: symbolRect.minY)

        ResistorImage.drawResistor(frame: CGRect(origin: .zero, size: symbolRect.size), resizing: .stretch, resistorValue: value1)
        context.restoreGState()


        //// Symbol 2 Drawing
        let symbol2Rect = CGRect(x: 154, y: 6, width: 153, height: 55)
        context.saveGState()
        context.clip(to: symbol2Rect)
        context.translateBy(x: symbol2Rect.minX, y: symbol2Rect.minY)

        ResistorImage.drawResistor(frame: CGRect(origin: .zero, size: symbol2Rect.size), resizing: .stretch, resistorValue: value2)
        context.restoreGState()


        //// Symbol 3 Drawing
        let symbol3Rect = CGRect(x: 299, y: 6, width: 153, height: 55)
        context.saveGState()
        context.clip(to: symbol3Rect)
        context.translateBy(x: symbol3Rect.minX, y: symbol3Rect.minY)

        ResistorImage.drawResistor(frame: CGRect(origin: .zero, size: symbol3Rect.size), resizing: .stretch, resistorValue: value3)
        context.restoreGState()
        
        context.restoreGState()

    }

    @objc dynamic public class func drawSeriesParallelResistors(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 359, height: 137), resizing: ResizingBehavior = .aspectFit, value1: String = "11.1K", value2: String = "22.2K", value3: String = "33.3K") {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 359, height: 137), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 359, y: resizedFrame.height / 137)


        //// Symbol Drawing
        let symbolRect = CGRect(x: 8, y: 6, width: 153, height: 55)
        context.saveGState()
        context.clip(to: symbolRect)
        context.translateBy(x: symbolRect.minX, y: symbolRect.minY)

        ResistorImage.drawResistor(frame: CGRect(origin: .zero, size: symbolRect.size), resizing: .stretch, resistorValue: value1)
        context.restoreGState()


        //// Symbol 2 Drawing
        let symbol2Rect = CGRect(x: 154, y: 6, width: 153, height: 55)
        context.saveGState()
        context.clip(to: symbol2Rect)
        context.translateBy(x: symbol2Rect.minX, y: symbol2Rect.minY)

        ResistorImage.drawResistor(frame: CGRect(origin: .zero, size: symbol2Rect.size), resizing: .stretch, resistorValue: value2)
        context.restoreGState()


        //// Symbol 3 Drawing
        let symbol3Rect = CGRect(x: 154, y: 73, width: 153, height: 55)
        context.saveGState()
        context.clip(to: symbol3Rect)
        context.translateBy(x: symbol3Rect.minX, y: symbol3Rect.minY)

        ResistorImage.drawResistor(frame: CGRect(origin: .zero, size: symbol3Rect.size), resizing: .stretch, resistorValue: value3)
        context.restoreGState()


        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 155, y: 110))
        bezierPath.addLine(to: CGPoint(x: 155, y: 44))
        UIColor.black.setStroke()
        bezierPath.lineWidth = 3
        bezierPath.lineCapStyle = .round
        bezierPath.stroke()


        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 150, y: 38, width: 10, height: 10))
        UIColor.black.setFill()
        ovalPath.fill()


        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 305, y: 109))
        bezier2Path.addLine(to: CGPoint(x: 305, y: 43))
        UIColor.black.setStroke()
        bezier2Path.lineWidth = 3
        bezier2Path.lineCapStyle = .round
        bezier2Path.stroke()


        //// Oval 2 Drawing
        let oval2Path = UIBezierPath(ovalIn: CGRect(x: 300, y: 38, width: 10, height: 10))
        UIColor.black.setFill()
        oval2Path.fill()


        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 305.5, y: 42.5))
        bezier3Path.addLine(to: CGPoint(x: 343.5, y: 42.5))
        UIColor.black.setStroke()
        bezier3Path.lineWidth = 3
        bezier3Path.lineCapStyle = .round
        bezier3Path.stroke()
        
        context.restoreGState()

    }

    @objc dynamic public class func drawParallelResistors(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 260, height: 205), resizing: ResizingBehavior = .aspectFit, value1: String = "11.1K", value2: String = "22.2K", value3: String = "33.3K") {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 260, height: 205), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 260, y: resizedFrame.height / 205)


        //// Symbol Drawing
        let symbolRect = CGRect(x: 55, y: 138, width: 153, height: 55)
        context.saveGState()
        context.clip(to: symbolRect)
        context.translateBy(x: symbolRect.minX, y: symbolRect.minY)

        ResistorImage.drawResistor(frame: CGRect(origin: .zero, size: symbolRect.size), resizing: .stretch, resistorValue: value1)
        context.restoreGState()


        //// Symbol 2 Drawing
        let symbol2Rect = CGRect(x: 56, y: 5, width: 153, height: 55)
        context.saveGState()
        context.clip(to: symbol2Rect)
        context.translateBy(x: symbol2Rect.minX, y: symbol2Rect.minY)

        ResistorImage.drawResistor(frame: CGRect(origin: .zero, size: symbol2Rect.size), resizing: .stretch, resistorValue: value2)
        context.restoreGState()


        //// Symbol 3 Drawing
        let symbol3Rect = CGRect(x: 56, y: 72, width: 153, height: 55)
        context.saveGState()
        context.clip(to: symbol3Rect)
        context.translateBy(x: symbol3Rect.minX, y: symbol3Rect.minY)

        ResistorImage.drawResistor(frame: CGRect(origin: .zero, size: symbol3Rect.size), resizing: .stretch, resistorValue: value3)
        context.restoreGState()


        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 57, y: 109))
        bezierPath.addLine(to: CGPoint(x: 57, y: 43))
        UIColor.black.setStroke()
        bezierPath.lineWidth = 3
        bezierPath.lineCapStyle = .round
        bezierPath.stroke()


        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 52, y: 37, width: 10, height: 10))
        UIColor.black.setFill()
        ovalPath.fill()


        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 207, y: 108))
        bezier2Path.addLine(to: CGPoint(x: 207, y: 42))
        UIColor.black.setStroke()
        bezier2Path.lineWidth = 3
        bezier2Path.lineCapStyle = .round
        bezier2Path.stroke()


        //// Oval 2 Drawing
        let oval2Path = UIBezierPath(ovalIn: CGRect(x: 202, y: 37, width: 10, height: 10))
        UIColor.black.setFill()
        oval2Path.fill()


        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 207.5, y: 41.5))
        bezier3Path.addLine(to: CGPoint(x: 245.5, y: 41.5))
        UIColor.black.setStroke()
        bezier3Path.lineWidth = 3
        bezier3Path.lineCapStyle = .round
        bezier3Path.stroke()


        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: 14.5, y: 41.5))
        bezier4Path.addLine(to: CGPoint(x: 52.5, y: 41.5))
        UIColor.black.setStroke()
        bezier4Path.lineWidth = 3
        bezier4Path.lineCapStyle = .round
        bezier4Path.stroke()


        //// Bezier 5 Drawing
        let bezier5Path = UIBezierPath()
        bezier5Path.move(to: CGPoint(x: 57, y: 175))
        bezier5Path.addLine(to: CGPoint(x: 57, y: 109))
        UIColor.black.setStroke()
        bezier5Path.lineWidth = 3
        bezier5Path.lineCapStyle = .round
        bezier5Path.stroke()


        //// Oval 3 Drawing
        let oval3Path = UIBezierPath(ovalIn: CGRect(x: 52, y: 103, width: 10, height: 10))
        UIColor.black.setFill()
        oval3Path.fill()


        //// Bezier 6 Drawing
        let bezier6Path = UIBezierPath()
        bezier6Path.move(to: CGPoint(x: 57, y: 109))
        bezier6Path.addLine(to: CGPoint(x: 57, y: 43))
        UIColor.black.setStroke()
        bezier6Path.lineWidth = 3
        bezier6Path.lineCapStyle = .round
        bezier6Path.stroke()


        //// Oval 4 Drawing
        let oval4Path = UIBezierPath(ovalIn: CGRect(x: 52, y: 37, width: 10, height: 10))
        UIColor.black.setFill()
        oval4Path.fill()


        //// Bezier 7 Drawing
        let bezier7Path = UIBezierPath()
        bezier7Path.move(to: CGPoint(x: 207, y: 175))
        bezier7Path.addLine(to: CGPoint(x: 207, y: 109))
        UIColor.black.setStroke()
        bezier7Path.lineWidth = 3
        bezier7Path.lineCapStyle = .round
        bezier7Path.stroke()


        //// Oval 5 Drawing
        let oval5Path = UIBezierPath(ovalIn: CGRect(x: 202, y: 103, width: 10, height: 10))
        UIColor.black.setFill()
        oval5Path.fill()
        
        context.restoreGState()

    }

    @objc dynamic public class func drawVoltageDivider(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 372, height: 112), resizing: ResizingBehavior = .aspectFit, value1: String = "11.1K", value2: String = "22.2K") {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 372, height: 112), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 372, y: resizedFrame.height / 112)


        //// Symbol Drawing
        let symbolRect = CGRect(x: 45, y: 13, width: 153, height: 55)
        context.saveGState()
        context.clip(to: symbolRect)
        context.translateBy(x: symbolRect.minX, y: symbolRect.minY)

        ResistorImage.drawResistor(frame: CGRect(origin: .zero, size: symbolRect.size), resizing: .stretch, resistorValue: value1)
        context.restoreGState()


        //// Symbol 2 Drawing
        let symbol2Rect = CGRect(x: 192, y: 13, width: 153, height: 55)
        context.saveGState()
        context.clip(to: symbol2Rect)
        context.translateBy(x: symbol2Rect.minX, y: symbol2Rect.minY)

        ResistorImage.drawResistor(frame: CGRect(origin: .zero, size: symbol2Rect.size), resizing: .stretch, resistorValue: value2)
        context.restoreGState()


        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 193.5, y: 81.5))
        bezierPath.addLine(to: CGPoint(x: 193, y: 50))
        UIColor.black.setStroke()
        bezierPath.lineWidth = 3
        bezierPath.lineCapStyle = .round
        bezierPath.stroke()


        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 188, y: 45, width: 10, height: 10))
        UIColor.black.setFill()
        ovalPath.fill()


        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 344.5, y: 50))
        bezier2Path.addLine(to: CGPoint(x: 344.5, y: 73))
        UIColor.black.setStroke()
        bezier2Path.lineWidth = 3
        bezier2Path.lineCapStyle = .square
        bezier2Path.lineJoinStyle = .round
        bezier2Path.stroke()


        //// Text 3 Drawing
        let text3Rect = CGRect(x: 19, y: 33, width: 20, height: 33)
        let text3TextContent = "V"
        let text3Style = NSMutableParagraphStyle()
        text3Style.alignment = .left
        let text3FontAttributes = [
            .font: UIFont(name: "HelveticaNeue-Bold", size: 30)!,
            .foregroundColor: UIColor.black,
            .paragraphStyle: text3Style,
        ] as [NSAttributedStringKey: Any]

        let text3TextHeight: CGFloat = text3TextContent.boundingRect(with: CGSize(width: text3Rect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: text3FontAttributes, context: nil).height
        context.saveGState()
        context.clip(to: text3Rect)
        text3TextContent.draw(in: CGRect(x: text3Rect.minX, y: text3Rect.minY + (text3Rect.height - text3TextHeight) / 2, width: text3Rect.width, height: text3TextHeight), withAttributes: text3FontAttributes)
        context.restoreGState()


        //// Polygon 2 Drawing
        context.saveGState()
        context.translateBy(x: 355.25, y: 91.5)
        context.rotate(by: -180 * CGFloat.pi/180)

        let polygon2Path = UIBezierPath()
        polygon2Path.move(to: CGPoint(x: 10.75, y: 0))
        polygon2Path.addLine(to: CGPoint(x: 20.06, y: 16.5))
        polygon2Path.addLine(to: CGPoint(x: 1.44, y: 16.5))
        polygon2Path.close()
        UIColor.black.setStroke()
        polygon2Path.lineWidth = 3
        polygon2Path.stroke()

        context.restoreGState()


        //// V * x Drawing
        let vXRect = CGRect(x: 169, y: 83, width: 48, height: 21)
        let vXTextContent = "V∙x"
        let vXStyle = NSMutableParagraphStyle()
        vXStyle.alignment = .center
        let vXFontAttributes = [
            .font: UIFont(name: "HelveticaNeue-Bold", size: 24)!,
            .foregroundColor: UIColor.black,
            .paragraphStyle: vXStyle,
        ] as [NSAttributedStringKey: Any]

        let vXTextHeight: CGFloat = vXTextContent.boundingRect(with: CGSize(width: vXRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: vXFontAttributes, context: nil).height
        context.saveGState()
        context.clip(to: vXRect)
        vXTextContent.draw(in: CGRect(x: vXRect.minX, y: vXRect.minY + (vXRect.height - vXTextHeight) / 2, width: vXRect.width, height: vXTextHeight), withAttributes: vXFontAttributes)
        context.restoreGState()
        
        context.restoreGState()

    }

    @objc dynamic public class func drawOpAmpGain(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 417, height: 163), resizing: ResizingBehavior = .aspectFit, value1: String = "11.1K", value2: String = "22.2K") {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 417, height: 163), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 417, y: resizedFrame.height / 163)


        //// Symbol Drawing
        let symbolRect = CGRect(x: 39, y: 29, width: 153, height: 55)
        context.saveGState()
        context.clip(to: symbolRect)
        context.translateBy(x: symbolRect.minX, y: symbolRect.minY)

        ResistorImage.drawResistor(frame: CGRect(origin: .zero, size: symbolRect.size), resizing: .stretch, resistorValue: value1)
        context.restoreGState()


        //// Symbol 3 Drawing
        let symbol3Rect = CGRect(x: 186, y: 96, width: 153, height: 55)
        context.saveGState()
        context.clip(to: symbol3Rect)
        context.translateBy(x: symbol3Rect.minX, y: symbol3Rect.minY)

        ResistorImage.drawResistor(frame: CGRect(origin: .zero, size: symbol3Rect.size), resizing: .stretch, resistorValue: value2)
        context.restoreGState()


        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 187, y: 133))
        bezierPath.addLine(to: CGPoint(x: 187, y: 67))
        UIColor.black.setStroke()
        bezierPath.lineWidth = 3
        bezierPath.lineCapStyle = .round
        bezierPath.stroke()


        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 182, y: 61, width: 10, height: 10))
        UIColor.black.setFill()
        ovalPath.fill()


        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 337, y: 132))
        bezier2Path.addLine(to: CGPoint(x: 337.5, y: 50.5))
        UIColor.black.setStroke()
        bezier2Path.lineWidth = 3
        bezier2Path.lineCapStyle = .round
        bezier2Path.stroke()


        //// Oval 2 Drawing
        let oval2Path = UIBezierPath(ovalIn: CGRect(x: 332, y: 43, width: 10, height: 10))
        UIColor.black.setFill()
        oval2Path.fill()


        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 314.5, y: 48.5))
        bezier3Path.addLine(to: CGPoint(x: 354.5, y: 48.5))
        UIColor.black.setStroke()
        bezier3Path.lineWidth = 3
        bezier3Path.lineCapStyle = .round
        bezier3Path.stroke()


        //// Polygon Drawing
        context.saveGState()
        context.translateBy(x: 314.25, y: 5.5)
        context.rotate(by: -270 * CGFloat.pi/180)

        let polygonPath = UIBezierPath()
        polygonPath.move(to: CGPoint(x: 43, y: 0))
        polygonPath.addLine(to: CGPoint(x: 80.24, y: 77.63))
        polygonPath.addLine(to: CGPoint(x: 5.76, y: 77.63))
        polygonPath.close()
        UIColor.black.setStroke()
        polygonPath.lineWidth = 3
        polygonPath.stroke()

        context.restoreGState()


        //// Text Drawing
        let textRect = CGRect(x: 241, y: 23, width: 14, height: 19)
        let textTextContent = "+"
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .left
        let textFontAttributes = [
            .font: UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .bold),
            .foregroundColor: UIColor.black,
            .paragraphStyle: textStyle,
        ] as [NSAttributedStringKey: Any]

        let textTextHeight: CGFloat = textTextContent.boundingRect(with: CGSize(width: textRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: textFontAttributes, context: nil).height
        context.saveGState()
        context.clip(to: textRect)
        textTextContent.draw(in: CGRect(x: textRect.minX, y: textRect.minY + (textRect.height - textTextHeight) / 2, width: textRect.width, height: textTextHeight), withAttributes: textFontAttributes)
        context.restoreGState()


        //// Text 2 Drawing
        let text2Rect = CGRect(x: 241, y: 56, width: 14, height: 19)
        let text2TextContent = "−"
        let text2Style = NSMutableParagraphStyle()
        text2Style.alignment = .left
        let text2FontAttributes = [
            .font: UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .bold),
            .foregroundColor: UIColor.black,
            .paragraphStyle: text2Style,
        ] as [NSAttributedStringKey: Any]

        let text2TextHeight: CGFloat = text2TextContent.boundingRect(with: CGSize(width: text2Rect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: text2FontAttributes, context: nil).height
        context.saveGState()
        context.clip(to: text2Rect)
        text2TextContent.draw(in: CGRect(x: text2Rect.minX, y: text2Rect.minY + (text2Rect.height - text2TextHeight) / 2, width: text2Rect.width, height: text2TextHeight), withAttributes: text2FontAttributes)
        context.restoreGState()


        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: 187.5, y: 65.5))
        bezier4Path.addLine(to: CGPoint(x: 236.5, y: 65.5))
        UIColor.black.setStroke()
        bezier4Path.lineWidth = 3
        bezier4Path.stroke()


        //// Text 3 Drawing
        let text3Rect = CGRect(x: 14, y: 50, width: 20, height: 33)
        let text3TextContent = "V"
        let text3Style = NSMutableParagraphStyle()
        text3Style.alignment = .left
        let text3FontAttributes = [
            .font: UIFont(name: "HelveticaNeue-Bold", size: 30)!,
            .foregroundColor: UIColor.black,
            .paragraphStyle: text3Style,
        ] as [NSAttributedStringKey: Any]

        let text3TextHeight: CGFloat = text3TextContent.boundingRect(with: CGSize(width: text3Rect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: text3FontAttributes, context: nil).height
        context.saveGState()
        context.clip(to: text3Rect)
        text3TextContent.draw(in: CGRect(x: text3Rect.minX, y: text3Rect.minY + (text3Rect.height - text3TextHeight) / 2, width: text3Rect.width, height: text3TextHeight), withAttributes: text3FontAttributes)
        context.restoreGState()


        //// Polygon 2 Drawing
        context.saveGState()
        context.translateBy(x: 198.25, y: 53.5)
        context.rotate(by: -180 * CGFloat.pi/180)

        let polygon2Path = UIBezierPath()
        polygon2Path.move(to: CGPoint(x: 10.75, y: 0))
        polygon2Path.addLine(to: CGPoint(x: 20.06, y: 16.5))
        polygon2Path.addLine(to: CGPoint(x: 1.44, y: 16.5))
        polygon2Path.close()
        UIColor.black.setStroke()
        polygon2Path.lineWidth = 3
        polygon2Path.stroke()

        context.restoreGState()


        //// Bezier 5 Drawing
        let bezier5Path = UIBezierPath()
        bezier5Path.move(to: CGPoint(x: 237.5, y: 31.5))
        bezier5Path.addLine(to: CGPoint(x: 186.5, y: 31.5))
        UIColor.black.setStroke()
        bezier5Path.lineWidth = 3
        bezier5Path.stroke()


        //// Bezier 6 Drawing
        let bezier6Path = UIBezierPath()
        bezier6Path.move(to: CGPoint(x: 187.5, y: 30.5))
        bezier6Path.addLine(to: CGPoint(x: 187.5, y: 36.5))
        UIColor.black.setStroke()
        bezier6Path.lineWidth = 3
        bezier6Path.stroke()


        //// V * x Drawing
        let vXRect = CGRect(x: 356, y: 36, width: 48, height: 21)
        let vXTextContent = "-V∙x"
        let vXStyle = NSMutableParagraphStyle()
        vXStyle.alignment = .center
        let vXFontAttributes = [
            .font: UIFont(name: "HelveticaNeue-Bold", size: 24)!,
            .foregroundColor: UIColor.black,
            .paragraphStyle: vXStyle,
        ] as [NSAttributedStringKey: Any]

        let vXTextHeight: CGFloat = vXTextContent.boundingRect(with: CGSize(width: vXRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: vXFontAttributes, context: nil).height
        context.saveGState()
        context.clip(to: vXRect)
        vXTextContent.draw(in: CGRect(x: vXRect.minX, y: vXRect.minY + (vXRect.height - vXTextHeight) / 2, width: vXRect.width, height: vXTextHeight), withAttributes: vXFontAttributes)
        context.restoreGState()
        
        context.restoreGState()

    }

    @objc dynamic public class func drawOpAmpGain2(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 417, height: 163), resizing: ResizingBehavior = .aspectFit, value1: String = "11.1K", value2: String = "22.2K") {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 417, height: 163), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 417, y: resizedFrame.height / 163)


        //// Symbol Drawing
        let symbolRect = CGRect(x: 39, y: 29, width: 153, height: 55)
        context.saveGState()
        context.clip(to: symbolRect)
        context.translateBy(x: symbolRect.minX, y: symbolRect.minY)

        ResistorImage.drawResistor(frame: CGRect(origin: .zero, size: symbolRect.size), resizing: .stretch, resistorValue: value1)
        context.restoreGState()


        //// Symbol 3 Drawing
        let symbol3Rect = CGRect(x: 186, y: 96, width: 153, height: 55)
        context.saveGState()
        context.clip(to: symbol3Rect)
        context.translateBy(x: symbol3Rect.minX, y: symbol3Rect.minY)

        ResistorImage.drawResistor(frame: CGRect(origin: .zero, size: symbol3Rect.size), resizing: .stretch, resistorValue: value2)
        context.restoreGState()


        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 187, y: 133))
        bezierPath.addLine(to: CGPoint(x: 187, y: 67))
        UIColor.black.setStroke()
        bezierPath.lineWidth = 3
        bezierPath.lineCapStyle = .round
        bezierPath.stroke()


        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 182, y: 61, width: 10, height: 10))
        UIColor.black.setFill()
        ovalPath.fill()


        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 337, y: 132))
        bezier2Path.addLine(to: CGPoint(x: 337.5, y: 50.5))
        UIColor.black.setStroke()
        bezier2Path.lineWidth = 3
        bezier2Path.lineCapStyle = .round
        bezier2Path.stroke()


        //// Oval 2 Drawing
        let oval2Path = UIBezierPath(ovalIn: CGRect(x: 332, y: 43, width: 10, height: 10))
        UIColor.black.setFill()
        oval2Path.fill()


        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 314.5, y: 48.5))
        bezier3Path.addLine(to: CGPoint(x: 354.5, y: 48.5))
        UIColor.black.setStroke()
        bezier3Path.lineWidth = 3
        bezier3Path.lineCapStyle = .round
        bezier3Path.stroke()


        //// Polygon Drawing
        context.saveGState()
        context.translateBy(x: 314.25, y: 5.5)
        context.rotate(by: -270 * CGFloat.pi/180)

        let polygonPath = UIBezierPath()
        polygonPath.move(to: CGPoint(x: 43, y: 0))
        polygonPath.addLine(to: CGPoint(x: 80.24, y: 77.63))
        polygonPath.addLine(to: CGPoint(x: 5.76, y: 77.63))
        polygonPath.close()
        UIColor.black.setStroke()
        polygonPath.lineWidth = 3
        polygonPath.stroke()

        context.restoreGState()


        //// Text Drawing
        let textRect = CGRect(x: 241, y: 23, width: 14, height: 19)
        let textTextContent = "+"
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .left
        let textFontAttributes = [
            .font: UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .bold),
            .foregroundColor: UIColor.black,
            .paragraphStyle: textStyle,
        ] as [NSAttributedStringKey: Any]

        let textTextHeight: CGFloat = textTextContent.boundingRect(with: CGSize(width: textRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: textFontAttributes, context: nil).height
        context.saveGState()
        context.clip(to: textRect)
        textTextContent.draw(in: CGRect(x: textRect.minX, y: textRect.minY + (textRect.height - textTextHeight) / 2, width: textRect.width, height: textTextHeight), withAttributes: textFontAttributes)
        context.restoreGState()


        //// Text 2 Drawing
        let text2Rect = CGRect(x: 241, y: 56, width: 14, height: 19)
        let text2TextContent = "−"
        let text2Style = NSMutableParagraphStyle()
        text2Style.alignment = .left
        let text2FontAttributes = [
            .font: UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .bold),
            .foregroundColor: UIColor.black,
            .paragraphStyle: text2Style,
        ] as [NSAttributedStringKey: Any]

        let text2TextHeight: CGFloat = text2TextContent.boundingRect(with: CGSize(width: text2Rect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: text2FontAttributes, context: nil).height
        context.saveGState()
        context.clip(to: text2Rect)
        text2TextContent.draw(in: CGRect(x: text2Rect.minX, y: text2Rect.minY + (text2Rect.height - text2TextHeight) / 2, width: text2Rect.width, height: text2TextHeight), withAttributes: text2FontAttributes)
        context.restoreGState()


        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: 187.5, y: 65.5))
        bezier4Path.addLine(to: CGPoint(x: 236.5, y: 65.5))
        UIColor.black.setStroke()
        bezier4Path.lineWidth = 3
        bezier4Path.stroke()


        //// Text 3 Drawing
        let text3Rect = CGRect(x: 177, y: 15, width: 20, height: 33)
        let text3TextContent = "V"
        let text3Style = NSMutableParagraphStyle()
        text3Style.alignment = .left
        let text3FontAttributes = [
            .font: UIFont(name: "HelveticaNeue-Bold", size: 30)!,
            .foregroundColor: UIColor.black,
            .paragraphStyle: text3Style,
        ] as [NSAttributedStringKey: Any]

        let text3TextHeight: CGFloat = text3TextContent.boundingRect(with: CGSize(width: text3Rect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: text3FontAttributes, context: nil).height
        context.saveGState()
        context.clip(to: text3Rect)
        text3TextContent.draw(in: CGRect(x: text3Rect.minX, y: text3Rect.minY + (text3Rect.height - text3TextHeight) / 2, width: text3Rect.width, height: text3TextHeight), withAttributes: text3FontAttributes)
        context.restoreGState()


        //// Polygon 2 Drawing
        context.saveGState()
        context.translateBy(x: 51.25, y: 119.5)
        context.rotate(by: -180 * CGFloat.pi/180)

        let polygon2Path = UIBezierPath()
        polygon2Path.move(to: CGPoint(x: 10.75, y: 0))
        polygon2Path.addLine(to: CGPoint(x: 20.06, y: 16.5))
        polygon2Path.addLine(to: CGPoint(x: 1.44, y: 16.5))
        polygon2Path.close()
        UIColor.black.setStroke()
        polygon2Path.lineWidth = 3
        polygon2Path.stroke()

        context.restoreGState()


        //// Bezier 5 Drawing
        let bezier5Path = UIBezierPath()
        bezier5Path.move(to: CGPoint(x: 237.5, y: 31.5))
        bezier5Path.addLine(to: CGPoint(x: 200.5, y: 31.5))
        UIColor.black.setStroke()
        bezier5Path.lineWidth = 3
        bezier5Path.stroke()


        //// V * x Drawing
        let vXRect = CGRect(x: 356, y: 36, width: 48, height: 21)
        let vXTextContent = "V∙x"
        let vXStyle = NSMutableParagraphStyle()
        vXStyle.alignment = .center
        let vXFontAttributes = [
            .font: UIFont(name: "HelveticaNeue-Bold", size: 24)!,
            .foregroundColor: UIColor.black,
            .paragraphStyle: vXStyle,
        ] as [NSAttributedStringKey: Any]

        let vXTextHeight: CGFloat = vXTextContent.boundingRect(with: CGSize(width: vXRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: vXFontAttributes, context: nil).height
        context.saveGState()
        context.clip(to: vXRect)
        vXTextContent.draw(in: CGRect(x: vXRect.minX, y: vXRect.minY + (vXRect.height - vXTextHeight) / 2, width: vXRect.width, height: vXTextHeight), withAttributes: vXFontAttributes)
        context.restoreGState()


        //// Bezier 6 Drawing
        let bezier6Path = UIBezierPath()
        bezier6Path.move(to: CGPoint(x: 40.5, y: 65.5))
        bezier6Path.addLine(to: CGPoint(x: 40.5, y: 103.5))
        UIColor.black.setStroke()
        bezier6Path.lineWidth = 3
        bezier6Path.stroke()
        
        context.restoreGState()

    }

    //// Generated Images

    @objc dynamic public class func imageOfSeriesResistors(value1: String = "11.1K", value2: String = "22.2K", value3: String = "33.3K") -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 466, height: 80), false, 0)
            ResistorImage.drawSeriesResistors(value1: value1, value2: value2, value3: value3)

        let imageOfSeriesResistors = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return imageOfSeriesResistors
    }

    @objc dynamic public class func imageOfSeriesParallelResistors(value1: String = "11.1K", value2: String = "22.2K", value3: String = "33.3K") -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 359, height: 137), false, 0)
            ResistorImage.drawSeriesParallelResistors(value1: value1, value2: value2, value3: value3)

        let imageOfSeriesParallelResistors = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return imageOfSeriesParallelResistors
    }

    @objc dynamic public class func imageOfParallelResistors(value1: String = "11.1K", value2: String = "22.2K", value3: String = "33.3K") -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 260, height: 205), false, 0)
            ResistorImage.drawParallelResistors(value1: value1, value2: value2, value3: value3)

        let imageOfParallelResistors = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return imageOfParallelResistors
    }

    @objc dynamic public class func imageOfVoltageDivider(value1: String = "11.1K", value2: String = "22.2K") -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 372, height: 112), false, 0)
            ResistorImage.drawVoltageDivider(value1: value1, value2: value2)

        let imageOfVoltageDivider = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return imageOfVoltageDivider
    }

    @objc dynamic public class func imageOfOpAmpGain(value1: String = "11.1K", value2: String = "22.2K") -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 417, height: 163), false, 0)
            ResistorImage.drawOpAmpGain(value1: value1, value2: value2)

        let imageOfOpAmpGain = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return imageOfOpAmpGain
    }

    @objc dynamic public class func imageOfOpAmpGain2(value1: String = "11.1K", value2: String = "22.2K") -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 417, height: 163), false, 0)
            ResistorImage.drawOpAmpGain2(value1: value1, value2: value2)

        let imageOfOpAmpGain2 = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return imageOfOpAmpGain2
    }




    @objc(ResistorImageResizingBehavior)
    public enum ResizingBehavior: Int {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.

        public func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }

            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)

            switch self {
                case .aspectFit:
                    scales.width = min(scales.width, scales.height)
                    scales.height = scales.width
                case .aspectFill:
                    scales.width = max(scales.width, scales.height)
                    scales.height = scales.width
                case .stretch:
                    break
                case .center:
                    scales.width = 1
                    scales.height = 1
            }

            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
}
