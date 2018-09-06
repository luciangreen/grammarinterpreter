/** Two Uses 2
%%twouses2([[i,ate,seed],[seed,satisfied,me]],g,[[g,n1,vp],[vp,v,n2],[n1,i],[n1,seed],[n2,seed],[n2,me],[v,ate],[v,satisfied]],[n1,n2,v],[n1,n2],[[i,me]],WordsWithTwoUses).

Input:
Sentences: %% Sentences to parse using grammar.
I swallowed seed.
Seed satisfied me.

GrammarName: %% Name of grammar.
g

Grammar: %% The sentences will be parsed according to the grammar, where g is grammar, n1 is noun 1, vp is verb phrase, v is verb, etc.
g->n1,vp
vp->v,n2
n1->i
n1->seed
n2->seed
n2->me
v->ate
v->satisfied

Terminals: %% Terminal grammar nodes to stop at.
n1,n2,v

POS: %% Parts of Speech (POS) to collect.
n1,n2

Synonyms: %% Count synonyms once in final output below.
i,me

Output:
SentencesWordsfromPOS: %% Words from each sentence that match the POS.
i,seed
seed,me

Final Output:
WordsWithTwoUses: %% Count two uses for (sentence instances of) SentencesWordsfromPOS.
i, seed

?- parsesentence1([i,ate,seed],_,g,[[g,n1,vp],[vp,v,n2],[n1,i],[n1,seed],[n2,seed],[n2,me],[v,ate],[v,satisfied]],[n1,n2,v],[n1,n2],[],SW).
SW = [i, seed] 

?- parsesentence1([seed,satisfied,me],_,g,[[g,n1,vp],[vp,v,n2],[n1,i],[n1,seed],[n2,seed],[n2,me],[v,ate],[v,satisfied]],[n1,n2,v],[n1,n2],[],SW).
SW = [seed, me] 

?- twouses2([[i,ate,seed],[seed,satisfied,me]],g,[[g,n1,vp],[vp,v,n2],[n1,i],[n1,seed],[n2,seed],[n2,me],[v,ate],[v,satisfied]],[n1,n2,v],[n1,n2],[[i,me]],WordsWithTwoUses).
WordsWithTwoUses = [i, seed] 

?- twouses2([[i,planted,the,plant],[i,ate,the,plant]],g,[[g,n1,vp],[vp,v,np],[np,d,n2],[d,the],[n1,i],[n2,plant],[v,planted],[v,ate]],[n1,n2,d,v],[n1,n2],[[]],WordsWithTwoUses).
WordsWithTwoUses = [i, plant]

?- twouses2([[the,gardener,picked,the,strawberry],[the,gardener,ate,the,strawberry]],g,[[g,np1,vp],[vp,v,np2],[np1,d,n1],[np2,d,n2],[d,the],[n1,gardener],[n2,strawberry],[v,picked],[v,ate]],[n1,n2,d,v],[n1,n2],[[]],WordsWithTwoUses).
WordsWithTwoUses = [gardener, strawberry]

?- twouses2([[i,licked,the,icecream],[the,icecream,was,delicious]],g,[[g,np1,vp],[vp,v,np2],[vp,v,pa],[np1,n1],[np1,d,n1],[np2,d,n2],[pa,delicious],[d,the],[n1,i],[n1,icecream],[n2,icecream],[v,licked],[v,was]],[n1,n2,d,v,pa],[n1,n2],[[]],WordsWithTwoUses).
WordsWithTwoUses = [icecream]

twouses2([[i,walked,my,dog],[the,canine,came]],g,[[g,np1,vp],[vp,v,np2],[vp,v],[np1,n1],[np1,d,n1],[np2,d,n2],[d,the],[d,my],[n1,i],[n1,canine],[n2,dog],[v,walked],[v,came]],[n1,n2,d,v],[n1,n2],[[dog,canine]],WordsWithTwoUses).
WordsWithTwoUses = [dog]

**/
twouses2(Sentences,GrammarName,Grammar,Terminals,POS,Synonyms,WordsWithTwoUses) :-
	Sentences = [Sentence1, Sentence2],
	parsesentence1(Sentence1,_,GrammarName,Grammar,Terminals,POS,[],Sentence1WordsfromPOS),
	parsesentence1(Sentence2,_,GrammarName,Grammar,Terminals,POS,[],Sentence2WordsfromPOS),
	replacesynonyms1(Sentence1WordsfromPOS,Synonyms,[],Sentence1WordsfromPOS2),
        replacesynonyms1(Sentence2WordsfromPOS,Synonyms,[],Sentence2WordsfromPOS2),
	counttwouses1([Sentence1WordsfromPOS2,Sentence2WordsfromPOS2],[],WordsWithTwoUses).
parsesentence1(Sentence1,Sentence2,GrammarName,Grammar,Terminals,POS,SentenceWordsfromPOS1,SentenceWordsfromPOS2) :-
	member(GrammarName,Terminals),
	member([GrammarName,Terminal],Grammar),
	Sentence1=[Terminal|Sentence2],
	addPOS(Terminal,GrammarName,POS,SentenceWordsfromPOS1,SentenceWordsfromPOS2),!.
parsesentence1(Sentence1,Sentence2,GrammarName,Grammar,Terminals,POS,SentenceWordsfromPOS1,SentenceWordsfromPOS2) :-
	member([GrammarName|GrammarRuleRest],Grammar),
	parsesentence2(Sentence1,Sentence2,GrammarRuleRest,Grammar,Terminals,POS,SentenceWordsfromPOS1,SentenceWordsfromPOS2).
parsesentence2(Sentence,Sentence,[],_Grammar,_Terminals,_POS,SentenceWordsfromPOS,SentenceWordsfromPOS) :-
	!.
parsesentence2(Sentence1,Sentence2,GrammarRuleRest,Grammar,Terminals,POS,SentenceWordsfromPOS1,SentenceWordsfromPOS2) :-
	GrammarRuleRest = [GrammarName|RestOfGrammar],
        parsesentence1(Sentence1,Sentence3,GrammarName,Grammar,Terminals,POS,SentenceWordsfromPOS1,SentenceWordsfromPOS3),
        parsesentence2(Sentence3,Sentence2,RestOfGrammar,Grammar,Terminals,POS,SentenceWordsfromPOS3,SentenceWordsfromPOS2).
addPOS(Terminal,GrammarName,POS,SentenceWordsfromPOS1,SentenceWordsfromPOS2) :-
	member(GrammarName,POS), append(SentenceWordsfromPOS1,[Terminal],SentenceWordsfromPOS2),!.
addPOS(_Terminal,GrammarName,POS,SentenceWordsfromPOS,SentenceWordsfromPOS) :-
        not(member(GrammarName,POS)).
replacesynonyms1([],_Synonyms,Sentence1WordsfromPOS,Sentence1WordsfromPOS) :-
	!.
replacesynonyms1(Sentence1WordsfromPOS1,Synonyms,Sentence1WordsfromPOS2,Sentence1WordsfromPOS3) :-
	Sentence1WordsfromPOS1 = [Word1 | Words],
	replacesynonyms2(Word1, Synonyms, Word2),
	append(Sentence1WordsfromPOS2,[Word2],Sentence1WordsfromPOS4),
	replacesynonyms1(Words,Synonyms,Sentence1WordsfromPOS4,Sentence1WordsfromPOS3).
replacesynonyms2(Word, [], Word) :-
	!.
replacesynonyms2(Word1, Synonyms1, Word2) :-
	Synonyms1=[Synonyms2|Synonyms3],
	replacesynonyms3(Word1,Synonyms2,Synonyms3,Word2).
replacesynonyms3(Word,Synonyms1,_Synonyms2,Word) :-
        not(member(Word,Synonyms1)),!.
replacesynonyms3(Word1,Synonyms1,_Synonyms2,Word2) :-
	member(Word1,Synonyms1),
	Synonyms1=[Word2|_Words],!.
replacesynonyms3(Word1,_Synonyms1,Synonyms2,Word2) :-
	replacesynonyms2(Word1,Synonyms2,Word2).
counttwouses1([Sentence1WordsfromPOS2,Sentence2WordsfromPOS2],WordsWithTwoUses1,WordsWithTwoUses2) :-
	Sentence1WordsfromPOS2=[Word1,Word2],
	counttwouses2(Word1,Sentence2WordsfromPOS2,WordsWithTwoUses1,WordsWithTwoUses3),
	counttwouses2(Word2,Sentence2WordsfromPOS2,WordsWithTwoUses3,WordsWithTwoUses2).
counttwouses2(Word,Sentence2WordsfromPOS2,WordsWithTwoUses,WordsWithTwoUses) :-
        not(member(Word,Sentence2WordsfromPOS2)),!.
counttwouses2(Word,Sentence2WordsfromPOS2,WordsWithTwoUses1,WordsWithTwoUses2) :-
	member(Word,Sentence2WordsfromPOS2),
	append(WordsWithTwoUses1,[Word],WordsWithTwoUses2).
