import { describe,it,expect } from 'vitest';
import { freshness, urgency, priority, haversineKm, ngoMatchScore, volunteerScore, reliabilityScore, estimatedImpact } from '../server/logic/scoring.js';
describe('deterministic rescue scoring',()=>{
 const now=new Date('2026-10-11T10:00:00Z');
 it('scores shelf life and urgency with expiry handled separately',()=>{expect(freshness(now,new Date(now.getTime()+1000),now,'Cooked Meals')).toBeGreaterThan(90);expect(freshness(now,new Date(now.getTime()-1),now)).toBe(0);expect(urgency(new Date(now.getTime()+3600000),now).band).toBe('CRITICAL');expect(urgency(new Date(now.getTime()+48*3600000),now).band).toBe('LOW');});
 it('keeps priority bounded and urgency weighted highest',()=>{expect(priority(100,100,100)).toBe(100);expect(priority(0,100,1)).toBeLessThan(priority(100,0,1));});
 it('calculates Chennai distance and rejects invalid coordinates',()=>{expect(haversineKm({lat:13.0418,lng:80.2341},{lat:13.0012,lng:80.2565})).toBeCloseTo(5.1,0);expect(()=>haversineKm({lat:91,lng:0},{lat:0,lng:0})).toThrow();});
 it('normalizes match, volunteer and confirmed impact values',()=>{expect(ngoMatchScore({category:100,requirement:100,distance:100,urgency:100,reliability:100,capacity:100,performance:100})).toBe(100);expect(volunteerScore({donorDistance:0,ngoDistance:0,capacity:0,workload:0,availability:0,reliability:0})).toBe(0);expect(estimatedImpact(10,.4,2.5,6)).toEqual({foodKg:4,meals:10,peopleServed:6,co2Kg:10});});
 it('calculates reliability from ratings and completed-versus-cancelled work',()=>{expect(reliabilityScore([],0,0)).toBe(75);expect(reliabilityScore([5,5],10,0)).toBe(100);expect(reliabilityScore([1],0,10)).toBeLessThan(40);});
});
