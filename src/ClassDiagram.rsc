module ClassDiagram

import lang::ofg::ast::FlowLanguage;
import lang::ofg::ast::Java2OFG;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

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
		//set[loc] methods = {m | m<- m@containment[cl], m.scheme == "java+method"};
		allClasses = allClasses + class(cl,cl.path[1..], class(), none(), pub(), {});
	
	}
	return allClasses;
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
	| aggregration(loc a, loc b, str name, int multiplicity_low, int multiplicity_high)
	| dependency(loc a, loc b)
	| generalization(loc a, loc b)
	| realization(loc a, loc b)
	| inner(loc a, loc b)
	| generic(loc a, loc b);