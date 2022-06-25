//
//  ContentView.swift
//  ProductPresentation
//
//  Created by Jakub Wrześniak on 21/05/2022.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    var scene = makeScene()
    var products = [
        Model(id: 0, name: "TV Set 1", modelName: "tvSet", details: "SomeT VSet"),
        Model(id: 1, name: "Old Tv", modelName: "tvOld", details: "Very old TV"),
        Model(id: 2, name: "Curved TV", modelName: "curvedTV", details: "Cyrved TV description")
    ]
    
    @State var selectedProduct = 0
    
    @State var isColorSheetVisible = false
    @State var isProductSheetVisible = false
    @State var isLightSheetVisible = false
    
    @State var wallColor: CGColor = CGColor(red: 0.56, green: 1, blue: 0, alpha: 1)
    
    @State var omnightLight: CGFloat = 100
    @State var spotLigth: CGFloat = 100
    @State var spotDirect: CGFloat = 100
    
    
    static func makeScene() -> SCNScene? {
        let scene = SCNScene(named: "art.scnassets/room.scn")
        return scene
    }
    
    init(){
        setUpTV()
        setWallsColor(to: wallColor)
        setUpMaterials()
    }
    
    func setUpMaterials(){
        let floorMaterial  = SCNMaterial()
        floorMaterial.lightingModel = .lambert
        floorMaterial.isDoubleSided = false
        floorMaterial.diffuse.contents = UIImage(named: "art.scnassets/carpetMaterial.jpeg")
        floorMaterial.ambient.contents = UIColor.white
        scene?.rootNode.childNode(withName: "floor", recursively: false)!.geometry?.materials = [floorMaterial]
        
        let dresserMaterial  = SCNMaterial()
        dresserMaterial.lightingModel = .lambert
        dresserMaterial.isDoubleSided = false
        dresserMaterial.diffuse.contents = UIImage(named: "art.scnassets/WoodMaterial.jpeg");
        dresserMaterial.ambient.contents = UIColor.white
        scene?.rootNode.childNode(withName: "dresser", recursively: false)!.geometry!.materials = [dresserMaterial]
        
        
    }
    
    func setLight(_ nodeName: String, value : CGFloat){
        let node = scene?.rootNode.childNode(withName: nodeName, recursively: false)!
        let light = node!.light
        if let light = light {
            light.intensity = value
        }
    }
    
    func getCamera() -> SCNNode? {
        let cameraNode = scene?.rootNode
            .childNode(withName: "Camera", recursively: false)
        return cameraNode
    }
    
    var body: some View {
        SceneView(scene: scene, pointOfView: getCamera(), options: [.allowsCameraControl])
            HStack{
                Button(action: {isProductSheetVisible.toggle()}){
                        Label("Product", systemImage: "tv")
                }
                .halfSheet(showSheet: $isProductSheetVisible)
                {
                    productSelectionStack()
                        .padding(.top, 50)
                        .padding(.horizontal, 50)
                }
                
                Spacer()
                Button(action: {isColorSheetVisible.toggle()}){
                        Label("Color", systemImage: "eyedropper")
                }
                .halfSheet(showSheet: $isColorSheetVisible)
                {
                    ColorPicker("Wall color", selection: $wallColor.onChange(setWallsColor), supportsOpacity: false)
                        .padding(.top, 50)
                        .padding(.horizontal, 50)
                }
                Spacer()
                Button(action: {isLightSheetVisible.toggle()}){
                        Label("Light", systemImage: "lightbulb")
                }
                .halfSheet(showSheet: $isLightSheetVisible)
                {
                    ligthView()
                        .padding(.horizontal, 10)
                        .padding(.top, 50)
                }
            }
            .padding(20)
    }
    
    func setProdust(_ product: Model){
        let productScene = getProductScene(product)
        let nodeArray = productScene.rootNode.childNodes
        for node in nodeArray {
            node.opacity = 0.0
            scene!.rootNode.childNode(withName: "product", recursively: true)!.addChildNode(node)
            node.runAction(SCNAction.fadeIn(duration: 1))
        }
    }
    
    func getProductScene(_ product: Model) -> SCNScene{
        let url = Bundle.main.url(forResource: product.modelName, withExtension: "dae",subdirectory: "art.scnassets")!
        let source = SCNSceneSource(url: url, options: nil)!
        return try! source.scene()
    }
    
    func setUpTV(){
        setProdust(products[0])
    }
    
    func setWallsColor(to value: CGColor) -> Void {
        let wallNodes = scene?.rootNode.childNodes.filter{
            $0.name!.contains("Wall")
        }
        if let wallNodes = wallNodes{
            for node in wallNodes {
                let material  = SCNMaterial()
                material.lightingModel = .lambert
                material.isDoubleSided = false
                material.diffuse.contents = UIColor(cgColor:  wallColor)
                node.geometry?.materials = [material]
            }
        }
        
    }
    
    func productSelectionStack() -> some View {
        ScrollView(.horizontal){
            HStack(spacing: 50){
                ForEach(products){ product in
                    VStack{
                        SceneView(scene: getProductScene(product), options: [.autoenablesDefaultLighting])
                            .onTapGesture{
                                let productNode = scene?.rootNode.childNode(withName: "product", recursively: false)
                                if let productNodes = productNode?.childNodes {
                                    for node in productNodes {
                                        node.runAction(SCNAction.fadeOut(duration: 1))
                                    }
                                }
                                Task{
                                    try! await Task.sleep(nanoseconds: 1_000_000_000)
                                    setProdust(product)
                                    selectedProduct = product.id
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width / 3 , height: UIScreen.main.bounds.height / 5)
                        Text(product.name)
                            .font(.title)
                        Text(product.details)
                    }
                }
            }
        }
    }
    
    func ligthView() -> some View{
        HStack(alignment: .center, spacing: 20){
            Group{
                lightToolView(light: $omnightLight.onChange(setMainLight), name: "Main light")
                lightToolView(light: $spotLigth.onChange(setCorenrLight), name: "Corner Light")
                lightToolView(light: $spotDirect.onChange(setDirectLight), name: "Direct Light")
            }
            .cornerRadius(15)
            .shadow(radius: 5)
        }
    }
    
    func setMainLight(to value: CGFloat){
        setLight("omniLight", value: value)
    }
    
    func setCorenrLight(to value: CGFloat){
        setLight("cornerLight", value: value)
    }
    
    func setDirectLight(to value: CGFloat){
        setLight("directLight", value: value)
    }
    
    func lightToolView(light: Binding<CGFloat>, name: String) -> some View {
        VStack(spacing: 30){
            Image(systemName: "lightbulb")
            Text(name)
            Slider(value: light, in: 0...1500, step: 10.0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
