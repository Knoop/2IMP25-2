module ClassDiagram

import lang::ofg::ast::FlowLanguage;
import lang::ofg::ast::Java2OFG;


data Project = project(set[Class] classes, set[ClassRelation] relations);

// Each class has a type, a modifier for that type and a set of declarations
data Class = class(loc id, ClassType cType, InheritanceModifier cIModifier, AccessModifier cAModifier, set[Decl] declarations);

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