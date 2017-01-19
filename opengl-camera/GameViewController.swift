//
//  GameViewController.swift
//  opengl-camera
//
//  Created by kyamada on 2017/01/19.
//  Copyright © 2017年 kyamada. All rights reserved.
//

// http://stackoverflow.com/questions/4662789/the-most-efficient-way-to-modify-cmsamplebuffer-contents


import GLKit
import OpenGLES
import AVFoundation

func BUFFER_OFFSET(_ i: Int) -> UnsafeRawPointer? {
    return UnsafeRawPointer(bitPattern: i)
}

class GameViewController: GLKViewController {

    let gVertices: [GLfloat] = [
//        -1.0, -1.0, 0.0,  // left top
//        -1.0,  1.0, 0.0,  // left bottom
//        1.0, -1.0, 0.0,   // right top
//        1.0,  1.0, 0.0,   // right bottom
        -1.0, -1.0,  // left top
        -1.0,  1.0,  // left bottom
        1.0, -1.0,   // right top
        1.0,  1.0,   // right bottom
    ]
    
    let texCoords: [GLfloat] = [
//        0.0, 0.0, // left top
//        0.0, 1.0, // left bottom
//        1.0, 0.0, // right top
//        1.0, 1.0, // right bottom
        0.0, 1.0, // 左下
        1.0, 1.0, // 右下
        0.0, 0.0, // 左上
        1.0, 0.0, // 右上
    ]
    
    let gIndices: [GLubyte] = [
        0,1,2,3
    ]
    
    let gColors: [GLfloat] = [
        1.0, 0.0, 0.0, 1.0,
        0.0, 1.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 1.0
    ]

    var vertexBuffer: GLuint = 0
    var indexBuffer: GLuint = 0
    var colorBuffer: GLuint = 0
    var textureBuffer: GLuint = 0
    
    var context: EAGLContext? = nil
    var effect: GLKBaseEffect? = nil
    var camera: Camera!
    
    deinit {
        self.tearDownGL()
        
        if EAGLContext.current() === self.context {
            EAGLContext.setCurrent(nil)
        }
        
        camera.stopRunning()
        camera = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.context = EAGLContext(api: .openGLES2)
        
        if !(self.context != nil) {
            print("Failed to create ES context")
        }
        
        let view = self.view as! GLKView
        view.context = self.context!
        view.drawableDepthFormat = .format24
        
        setupGL()
        camera = Camera(delegate: self)
        camera.startRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if self.isViewLoaded && (self.view.window != nil) {
            self.view = nil
            
            self.tearDownGL()
            
            if EAGLContext.current() === self.context {
                EAGLContext.setCurrent(nil)
            }
            self.context = nil
        }
    }
    
    func setupGL() {
        EAGLContext.setCurrent(self.context)
        
        self.effect = GLKBaseEffect()
        self.effect?.colorMaterialEnabled = GLboolean(GL_TRUE)
        
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<GLfloat>.size * gVertices.count), gVertices, GLenum(GL_STATIC_DRAW))
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 3), BUFFER_OFFSET(0))
        
        glGenBuffers(1, &colorBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), colorBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<GLfloat>.size * gColors.count), gColors, GLenum(GL_STATIC_DRAW))
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.color.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 4), BUFFER_OFFSET(0))
        
        glGenBuffers(1, &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER),indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER),GLsizeiptr(MemoryLayout<GLuint>.size * gIndices.count),gIndices,GLenum(GL_STATIC_DRAW))
        

    }
    
    // MARK: - GLKView and GLKViewController delegate methods
    
    func update() {
     
    }
    
    func drawTexture() {
        if textureBuffer == 0 {
            return
        }
        
        // テクスチャの描画
        glTexCoordPointer(2, GLenum(GL_FLOAT), 0, texCoords);
        
        // Step6. テクスチャの画像指定
        glBindTexture(GLenum(GL_TEXTURE_2D), textureBuffer);
        
        // Step7. テクスチャの描画
        glEnable(GLenum(GL_TEXTURE_2D))
        glEnableClientState(GLenum(GL_VERTEX_ARRAY))
        glEnableClientState(GLenum(GL_TEXTURE_COORD_ARRAY))
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
        glDisableClientState(GLenum(GL_TEXTURE_COORD_ARRAY))
        glDisableClientState(GLenum(GL_VERTEX_ARRAY))
        glDisable(GLenum(GL_TEXTURE_2D))
    }
    
    func tearDownGL() {
        EAGLContext.setCurrent(self.context)
        
        glDeleteBuffers(1, &vertexBuffer)
        glDeleteBuffers(1, &indexBuffer)
        glDeleteBuffers(1, &colorBuffer)
    }
    
    // MARK: - GLKView and GLKViewController delegate methods
    
//    func update() {
//        let aspect = fabsf(Float(self.view.bounds.size.width / self.view.bounds.size.height))
//        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 0.1, 100.0)
//        
//        self.effect?.transform.projectionMatrix = projectionMatrix
//        
//        var baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -4.0)
//        baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, rotation, 0.0, 1.0, 0.0)
//        
//        // Compute the model view matrix for the object rendered with GLKit
//        var modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -1.5)
//        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, rotation, 1.0, 1.0, 1.0)
//        modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix)
//        
//        self.effect?.transform.modelviewMatrix = modelViewMatrix
//        
//        // Compute the model view matrix for the object rendered with ES2
//        modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, 1.5)
//        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, rotation, 1.0, 1.0, 1.0)
//        modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix)
//        
//        normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), nil)
//        
//        modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix)
//        
//        rotation += Float(self.timeSinceLastUpdate * 0.5)
//    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(0.65, 0.65, 0.65, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        // Render the object with GLKit
        self.effect?.prepareToDraw()
        
        //drawTexture()
        
        glDrawElements(GLenum(GL_TRIANGLE_STRIP), GLsizei(gIndices.count), GLenum(GL_UNSIGNED_BYTE),BUFFER_OFFSET(0))
    }
    
    // Note the caller is responsible for calling glDeleteTextures on the return value.
    func textureFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> GLuint {
        var texture: GLuint = 0;
        
        glGenTextures(1, &texture);
        glBindTexture(GLenum(GL_TEXTURE_2D), texture);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        
        let pixelBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let width: Int = CVPixelBufferGetWidth(pixelBuffer) / 4
        let height: Int = CVPixelBufferGetHeight(pixelBuffer) / 4
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(width), GLsizei(height), 0, GLenum(GL_BGRA), GLenum(GL_UNSIGNED_BYTE), CVPixelBufferGetBaseAddress(pixelBuffer));
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0));
        
        return texture;
    }
}

extension GameViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        //let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
//        textureBuffer = textureFromSampleBuffer(sampleBuffer: sampleBuffer)

    }
}
