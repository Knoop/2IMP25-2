module Program2OFG
import lang::ofg::ast::FlowLanguage;
import lang::ofg::ast::Java2OFG;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::TypeSymbol;

import List;
import Set;
import Relation;
import String;

import IO;

alias OFG = rel[loc from, loc to];
set[loc] unresolved = {|id:///|, |unresolved:///this|, |unresolved:///|};

OFG createOFGFromProgram(Program program){
	OFG ofg = initialEdgesOFG(program);  
	// ofg contains ids that are unusable, remove those. 
 	ofg = {<source, target> | <source, target> <- ofg, (source notin unresolved), (target notin unresolved)};
 	// The result is applying forward and backward propagation to our cleaned OFG.
  	return propagate(ofg, program, { }, true) + propagate(ofg, program, { }, false);
}

//builds initial edges according to the rules as defined in section 2.2 of the book by Tonella and Potrich
OFG initialEdgesOFG(Program prog) 
  = { <as[i], fps[i]> | newAssign(x, cl, c, as) <- prog.statements, constructor(c, fps) <- prog.decls, i <- index(as) }
  + { <cs + "this", x> | newAssign(x, _, cs, _) <- prog.statements }
  + { <s, t> | assign(t, _, s) <- prog.statements }
  + { <r, m + "this"> | call(_, _, r, m, _) <- prog.statements }
  + { <m + "return", t> | call(t, _, _, m, _) <- prog.statements }
  + { <as[i], fps[i]> | call(_, _, _, m, as) <- prog.statements, method(m, fps) <- prog.decls, i <- index(as) }
  ;

//applies the propagation algorithm either forward or backwards, to obtain hidden relations.
OFG propagate(OFG ofg, Program prog, rel[loc,loc] kill, bool back) {
  rel[loc, loc] gen;

  if (!back) {
    gen = { <constr + "this", class> | newAssign(_, class, constr, _) <- prog.statements, constructor(constr, _) <- prog.decls };
  }
  else {
    gen = { <s, ca> | assign(t, ca, s) <- prog.statements, ca != emptyId }
      + { <m + "return", ca> | call(t, ca, _, m, _) <- prog.statements, ca != emptyId };
  }
	
  OFG IN = { };
  OFG OUT = gen + (IN - kill);
  invertedOfg = { <to,from> | <from, to> <- ofg};
  set[loc] pred(loc n) = invertedOfg[n];
  set[loc] succ(loc n) = ofg[n];
	  
  solve (IN, OUT) {
    IN = { <n,\o> | n <- carrier(ofg), x <- (!back ? pred(n) : succ(n)), \o <- OUT[x] };
    OUT = gen + (IN - kill);
  }
  return OUT;			
}
