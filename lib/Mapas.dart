import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: must_be_immutable
class Mapas extends StatefulWidget {
  String idViagem;

  Mapas({this.idViagem});
  @override
  _MapasState createState() => _MapasState();
}

class _MapasState extends State<Mapas> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _marcador = {};
  CameraPosition _posicaoCamera =
      CameraPosition(target: LatLng(-22.566646, -44.944673), zoom: 18);
  Firestore _db = Firestore.instance;

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _adicionarMarcador(LatLng latLng) async {
    List<Placemark> listaEnderecos = await Geolocator()
        .placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    if (listaEnderecos != null && listaEnderecos.length > 0) {
      Placemark endereco = listaEnderecos[0];

      String rua = endereco.thoroughfare;

      Marker marcadorClicado = Marker(
          markerId: MarkerId("Local Selecionado"),
          infoWindow: InfoWindow(title: rua),
          position: latLng);

      setState(() {
        _marcador.add(marcadorClicado);

        //salvar no firebase
        Map<String, dynamic> viagem = Map();
        viagem["titulo"] = rua;
        viagem["latidude"] = latLng.latitude;
        viagem["longitude"] = latLng.longitude;

        _db.collection("Viagens").add(viagem);
      });
    }
  }

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(_posicaoCamera));
  }

  _adicionarListenerLocalizacao() {
    var geolocator = Geolocator();
    var locationOptions = LocationOptions(accuracy: LocationAccuracy.high);
    geolocator.getPositionStream(locationOptions).listen((Position position) {
      setState(() {
        _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 18);
      });
      _movimentarCamera();
    });
  }

  _recuperarViagemParaId(String idVigem) async {
    if (idVigem != null) {
      DocumentSnapshot documentSnapshot =
          await _db.collection("Viagens").document(idVigem).get();

      var dados = documentSnapshot.data;
      String titulo = dados["titulo"];
      LatLng latLng = LatLng(dados["latidude"], dados["longitude"]);

      setState(() {
        Marker marcadores = Marker(
            markerId: MarkerId("Local Selecionado"),
            infoWindow: InfoWindow(title: titulo),
            position: latLng);

        _marcador.add(marcadores);
        _posicaoCamera = CameraPosition(target: latLng, zoom: 16);
        _movimentarCamera();
      });
    } else {
      _adicionarListenerLocalizacao();
    }
  }

  @override
  void initState() {
    super.initState();
    //  _adicionarListenerLocalizacao();
    _recuperarViagemParaId(widget.idViagem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa"),
      ),
      body: Container(
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _posicaoCamera,
          markers: _marcador,
          onMapCreated: _onMapCreated,
          onLongPress: _adicionarMarcador,
        ),
      ),
    );
  }
}
