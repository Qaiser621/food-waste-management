import { useMemo, useState } from 'react';
import { MapContainer, Marker, Polyline, Popup, TileLayer } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { haversineKm } from '../../server/logic/scoring.js';

type Props={donorLat:number|null;donorLng:number|null;ngoLat:number|null;ngoLng:number|null;donorAddress:string;ngoAddress:string};
export default function MapCard({donorLat,donorLng,ngoLat,ngoLng,donorAddress,ngoAddress}:Props){
 const [tileError,setTileError]=useState(false);
 const donorIcon=useMemo(()=>L.divIcon({className:'smart-map-pin donor-pin',html:'<span></span>',iconSize:[20,20],iconAnchor:[10,10]}),[]),ngoIcon=useMemo(()=>L.divIcon({className:'smart-map-pin ngo-pin',html:'<span></span>',iconSize:[20,20],iconAnchor:[10,10]}),[]);
 const coords=[donorLat,donorLng,ngoLat,ngoLng];
 if(coords.some(x=>x==null||!Number.isFinite(x)))return <div className="map-fallback"><b>Route map unavailable</b><p>{donorAddress} → {ngoAddress}</p><small>Location coordinates are missing for this rescue.</small></div>;
 const from:[number,number]=[donorLat!,donorLng!],to:[number,number]=[ngoLat!,ngoLng!],distance=haversineKm({lat:from[0],lng:from[1]},{lat:to[0],lng:to[1]}),minutes=Math.round(distance/20*60),center:[number,number]=[(from[0]+to[0])/2,(from[1]+to[1])/2];
 return <section className="map-card" aria-label="Estimated rescue route"><div className="map-heading"><b>Estimated route</b><span>{distance.toFixed(1)} km · about {minutes} min at 20 km/h</span></div><div className="map-frame"><MapContainer center={center} zoom={12} scrollWheelZoom={false} style={{height:'100%',width:'100%'}}><TileLayer attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors' url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" eventHandlers={{tileerror:()=>setTileError(true)}}/><Polyline positions={[from,to]} pathOptions={{color:'#13815c',weight:4,dashArray:'8 8'}}/><Marker position={from} icon={donorIcon}><Popup>Donor pickup · {donorAddress}</Popup></Marker><Marker position={to} icon={ngoIcon}><Popup>Receiving NGO · {ngoAddress}</Popup></Marker></MapContainer>{tileError&&<div className="map-warning">Map tiles are offline; route estimate and locations are still shown.</div>}</div><small>Distance follows a straight-line estimate. Travel time assumes 20 km/h; this is not live road navigation.</small></section>;
}
