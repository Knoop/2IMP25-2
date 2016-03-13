module ClassDiagram

import lang::ofg::ast::FlowLanguage;
import lang::ofg::ast::Java2OFG;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import IO;
import ListRelation;
import vis::Figure; 
import vis::Render;

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
	for(cl <- classes(m)){
	getMethods(m,cl);
		allClasses += class(cl,cl.path[1..], class(), getIM(m,cl), getAM(m,cl), {});
	}
	return allClasses;
}

private list[loc] getMethods(M3 m, loc l){
	met = [ e | e <- m@containment[l], e.scheme == "java+method"];
	println(met);
	return met;
}

private AccessModifier getAM(M3 m, loc l ){
  	for(modi <- m@modifiers[l] ){
		switch(modi){
			case \final(): ;
			case \abstract(): ;
			case \public(): return pub();
			case \protected(): return pro();
			case \private(): return pri();
		}
	}
	return def();
}

private InheritanceModifier getIM(M3 m, loc l ){
	for(modi <- m@modifiers[l] ){
		switch(modi){
			case \final(): return final();
			case \abstract(): return abstract();
			case \public(): ;
			case \protected(): ;
			case \private(): ;
		}
	}
	return none();
}

//private set[method] makeMethods(M3 m3model, class cl){
//	list[loc] methodsSet = { m | m <- M3model@containment[cl], m.scheme == "java+method"};

//}

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



// Each class has a type, a modifier for that type and a set of declarations
data Class = class(loc id, str name, ClassType cType, InheritanceModifier cIModifier, AccessModifier cAModifier, set[Decl] declarations);

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