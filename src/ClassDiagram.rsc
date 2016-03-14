module ClassDiagram

import lang::ofg::ast::FlowLanguage;
import lang::ofg::ast::Java2OFG;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::TypeSymbol;

import IO;
import ListRelation;
import vis::Figure; 
import vis::Render;
import Set;
import List;
import Type;
import Map;
import Relation;
import String;
import util::ValueUI;
import util::Math;

data Project = project(set[Class] classes, set[ClassRelation] relations);


public Project makeProject(loc projectLocation){
	
	// Obtain M3 and OFG
	m = createM3FromEclipseProject(projectLocation);
	p = createOFG(projectLocation);
	
	allClasses = makeClasses(m);
	
	allRelations = makeClassRelations(allClasses, m, p);
	
	return project(allClasses, allRelations);
	
}

// Creates a set of all classes from the given M3. 
private set[Class] makeClasses(M3 m){
	set[Class] allClasses = {};
	
	// Create a set of all interfaces
	for(cl <- interfaces(m)){
		allClasses += getClasses(m,cl, "Interface");
	}
	
	// Create a set of all enumerations
	for(cl <- enums(m)){
		allClasses += getClasses(m,cl, "Enumeration");	
	}
	
	// Create a set of all anonymous classes
	for(cl <- anonymousClasses(m)){
		allClasses += getClasses(m,cl, "Anonymous class");
	}
	
	// Create a set of all normal classes
	for(cl <- classes(m)){
		allClasses += getClasses(m,cl, "Class");
	}
	return allClasses;
}
private Class getClasses(M3 m, loc cl, str cType){
	// get all methods 
	set[Method] allMethods = getMethods(m,cl);
	// get all attributes
	set[Attribute ] allAttributes = getAttributes(m,cl);
	// get all inner classes
	set[loc] innerClassSet = { e | e <- m@containment[cl], isClass(e)};
	for(l<- innerClassSet){
		getClasses(m,l,cType);
	}
	return class(cl,cl.path[1..], cType, getIM(m,cl), getAM(m,cl),allAttributes, allMethods);
}


private set[Attribute] getAttributes(M3 m, loc l){
	set[Attribute] allAttributes = {};
	// get all attributes
	set[loc] attributeSet = {e | e<- m@containment[l], isField(e)}; 
	
	// get the types that mather
	typeAttribute = domainR(m@types, attributeSet);
	modifierAttribute = domainR(m@modifiers, attributeSet);
	iNames = invert(m@names);
	
	// get the name, return type and modifiers that define an attribute
	for( att <- attributeSet){
		allAttributes += 
		attribute(
			getOneFrom(iNames[att]),
			getReturnType(getOneFrom(typeAttribute[att]), iNames),
			getModiMeth(modifierAttribute[att])
		) ;
	}
	return allAttributes;
}

private set[Method] getMethods(M3 m, loc l){
	set[Method] allMethods = {};
	// get all methods
	set[loc] methodSet = { e | e <- m@containment[l], isMethod(e)};
	
	// get all the types that mather
	typeMethod = domainR(m@types, methodSet);
	modifierMethod = domainR(m@modifiers, methodSet);
	iNames= invert(m@names);
	
	// get the name, return type and modifiers that define a method
	for(met <- methodSet){
		allMethods += 
			method(
				getOneFrom(iNames[met]),
				getReturnType(getOneFrom(typeMethod[met]), iNames),
				getModiMeth(modifierMethod[met])
			); 
	}
	return allMethods;
}

// translate modifiers to readable format
private str getModiMeth(set[Modifier] modi){
	str result = "";
	for(m<- modi){
		if(m == \static()){
			result += "s";
		}
	}
	for(m<- modi){
		switch(m){
			case \public(): result += "+";
			case \private(): result += "-"; 
			case \protected(): result += "#"; 
			case \package(): result += "~";
			case \derived(): result += "/";  
		}
	}
	return result;
}

// translate access modifiers to readable format
private str getAM(M3 m, loc l ){
  	for(modi <- m@modifiers[l] ){
		switch(modi){
			case \final(): ;
			case \abstract(): ;
			case \public(): return "public";
			case \protected(): return "protected";
			case \private(): return "private";
		}
	}
	return "";
}
 
// translate inheretance modifiers to readable format
private str getIM(M3 m, loc l ){
	for(modi <- m@modifiers[l] ){
		switch(modi){
			case \final(): return "final";
			case \abstract(): return "abstract";
			case \public(): ;
			case \protected(): ;
			case \private(): ;
		}
	}
	return "";
}

// translate return types to readable format
private str getReturnType(TypeSymbol t, rel[loc,str] iNames){
	switch(t){
		case \int(): return "int";
		case \short(): return "short";
		case \boolean(): return "boolean";
		case \long(): return "long";
		case \char(): return "char";
		case \byte(): return "byte";
		case \object(): return "object";
		case \void(): return "void";
		case \class(clName, clList) : 
			return getOneFrom(iNames[clName]);
		case \interface(clName, clList) : 
			return getOneFrom(iNames[clName]);
		case \method(ml, fp, returnType, x) :
			return getReturnType(returnType, iNames);
		case \array(oName, dim) : 
			return getReturnType(oName, iNames) + "[<dim>]";
		case \constructor(loc clName, cType) : 
			return getOneFrom(iNames[clName]); 
	}
	
	return "Return type not readable <t>";
}

private set[ClassRelation] makeClassRelations(set[Class] allClasses, M3 m, Program p){

	set[ClassRelation] relations = {};

	for(<from, to> <- m@extends){
		relations += generalization(to, from);
	}
	
	for(<from, to> <- m@implements){
		relations += realization(to, from);
	}
	
	
	return relations;
}

set[loc] anonymousClasses(M3 m) = { e | e <- m@declarations<name>, e.scheme == "java+anonymousClass" };

data Class = class(loc id, str name, str cType, str cIModifier, str cAModifier,set[Attribute] attributeSet, set[Method] methodset);

// Each class has a type, a modifier for that type and a set of declarations
data Method = method(str name, str returntype, str mModifier);
data Attribute = attribute(str name, str aType, str aModififier);
data ClassType 
 	= enum()
 	| interface()
 	| class()
 	;
 	
data AccessModifier 
	= pub()
	| pro()
	| pri()
	| def()
	;

data InheritanceModifier
	= final()
	| abstract()
	| none();
	
data ClassRelation
	= association(loc a, loc b, str name, int multiplicity_low, int multiplicity_high)
	| dependency(loc a, loc b)
	| generalization(loc a, loc b)
	| realization(loc a, loc b)
	| inner(loc a, loc b)
	| generic(loc a, loc b);