
/* Spamventure! */
%% starter file by Ran Libeskind-Hadas
%% and modified by Z Dodds
%
%  Name: Maureen Naval
%  Submission site username: mnaval
%  Partners: None
%  Time spent: 20 hours (I enjoyed every minute of it, though!)
%
/*
  Comments:

  This "spamventure game is based off of the infamous PS3
  game, The Last of Us.

  SPOILER ALERT: If you have never played but do intend on
  playing this game in the future, you will know the entire
  story and thus ruin the suspense for yourself when
  you play the wonderful game.

  Note: There's a lot of reading involved because I wanted
  there to be a story with character development. Sorry
  if you don't like reading! I won't be offended if you
  just follow the instructions here without reading
  the actual story (but the actual game has a BEAUTIFUL plot!).

  Steps to win the game:
  1. start.
  2. Boston:
            take(gun).
	    take(shiv).
	    use(shiv).
            proceed.
  3. Pittsburgh:
            OPTIONAL:
	    If you'd like more dialog between Joel and Ellie,
	    take and read the note
	       take(note).
               use(note).
               drop(note).
            NOT OPTIONAL PART:
	    take('shiv 2').
            use('shiv 2').
	    proceed.
  4. Wyoming:
	    take(brick).
	    use(brick).
	    proceed.
  5. Colorado:
	    take('medical kit').
	    use('medical kit').
	    proceed.
  6. Mountains:
	    take('bow and arrow').
	    use('bow and arrow').
	    proceed.
  7. Salt Lake City:
            drop('bow and arrow').
	    take('ammo').
	    use(gun).
	    proceed.

  ADDITIONAL FEATURES:
  - Killing enemies

  EXTRA CREDIT:
  - Restart predicate
  - Story with dialog
  - Making object only have one-time use
  - Need certain weapons for certain enemies
    (Ex: Shiv --> SPAM / Gun--> Marlene /)
  - Die when you do not have gun equipped

*/


% some "nice" prolog settings...  see assignment 8's
% description for the details on what these do
% -- but it's not crucial to know the details of these Prolog internals
:- set_prolog_flag( prompt_alternatives_on, groundness ).
:- set_prolog_flag(toplevel_print_options, [quoted(true),
     portray(true), attributes(portray), max_depth(999), priority(699)]).


%% thing_at(X, Y) will be true iff thing X is at location Y.
%% player_at(X) will be true iff player is at location X.
%% The use of dynamic should be at the beginning of the file when
%% we plan to mix static and dynamic facts with the same names.

:- dynamic thing_at/2, i_am_at/1, alive/1.


%% i_am_at defines the player's current location.
%
%  The player is initially in Boston, Massachusetts.
i_am_at(boston).





%% path(X, Y, Z) is true iff there is a path
%                from X to Z via direction Y.
%  path describes how the places are connected
%
path(boston, proceed, pittsburgh).
path(pittsburgh, return, boston).

path(pittsburgh, proceed, wyoming).
path(wyoming, return, pittsburgh).

path(wyoming, proceed, colorado).
path(colorado, return, wyoming).

path(colorado, proceed, mountains).
path(mountains, return, colorado).

path(mountains, proceed, 'salt lake city').
path('salt lake city', return, mountains).

path('salt lake city', proceed, 'Tommy\'s settlement').





%% thing_at(X, Y) is true iff thing X is at location Y.
%  thing_at tells where the objects in the game are located
%
%  Supplies:
thing_at(gun, boston).
thing_at(shiv, boston).
thing_at('shiv 2', pittsburgh).
thing_at(note, pittsburgh).
thing_at(brick, wyoming).
thing_at('medical kit', colorado).
thing_at('bow and arrow', mountains).
%  Enemies:
thing_at('group of infected SPAM coming your way', boston).
thing_at('herd of infected SPAM', pittsburgh).
thing_at('group of bandits in the distance', wyoming).
thing_at(cannibal, mountains).
thing_at(ammo, 'salt lake city').
thing_at('Marlene', 'salt lake city').





% alive(Enemy) sets the conditions of enemies which are
%  initially alive because player has not
%  defeated them yet
%
alive('group of infected SPAM coming your way').
alive('herd of infected SPAM').
alive('group of bandits in the distance').
alive(cannibal).
alive('Marlene').





%% take(X) allows players to pick up items.
%
%  Cannot pick up an enemy
take(X) :-
   ( X == 'group of infected SPAM coming your way';
    X == 'herd of infected SPAM';
    X == 'group of bandits in the distance';
    X == cannibal;
    X == 'Marlene' ),
    write('You cannot pick up an enemy!').
%  Cannot pick up an object that you are already holding
take(X) :-
    thing_at(X, in_hand),
    nl, write('You are already holding that.'),
    nl.
% Cannot pick up an object if you already carry two
take(_) :-
	listOfItemsInHand(L),
	length(L, 2),
	write('You can\'t carry anymore items!'), nl.
take(X) :-
    i_am_at(Place),
    thing_at(X, Place),
    retract(thing_at(X, Place)),
    assert(thing_at(X, in_hand)),
    nl, write('You picked up a '), write(X),
    nl.
% Cannot pick up an object that isn't there
take(_) :-
	write('I don\'t see it here.'),
	nl.





%% drop(X) allows players to drop items.
%
drop(X) :-
	thing_at(X, in_hand),
	i_am_at(Place),
	retract(thing_at(X, in_hand)),
	assert(thing_at(X, Place)),
	write('You no longer carry a '), write(X), write('.'),
	nl.
%  Cannot drop an object that you aren't holding
drop(_) :-
	write('You aren\'t holding it!'),
	nl.




%% "inventory" allows the player to check items in hand
%
inventory :-
	listOfItemsInHand(L),
	write('You are currently holding:'), nl,
	write(L), write('.'), nl.





%% listOfItemsInHand( L ) binds L to the list
%    of items X that satisfy the predicate thing_at(X, in_hand)
% base case - empty list
listOfItemsInHand([]) :- \+setof( X, thing_at(X,in_hand), _).
% general case - nonempty list
listOfItemsInHand( L ) :- setof( X, thing_at(X,in_hand), L ).





%% These rules define the directions.
%  proceed allows the player to go to the next location.
%  return allows the player to return to a previous location.
%
proceed :- go(proceed).
return :- go(return).




%% go(Direction) tells how to move in a given direction
%
go(proceed) :-
    i_am_at(Here),
    path(Here, proceed, There),
    retract(i_am_at(Here)),
    assert(i_am_at(There)),
    nl,
    look, nl,
    notice_objects_at(There), nl.

% Do not describe place if player has already been there
go(return) :-
    i_am_at(Here),
    path(Here, return, There),
    retract(i_am_at(Here)),
    assert(i_am_at(There)),
    write('You have returned to '), write(There), write('.'), nl,
    notice_objects_at(There),
    nl.

% Can only go to locations depending on defined paths above
go(Direction) :-
    i_am_at(Here),
    \+path(Here, Direction, _),
    write('You cannot go that way.'), nl.





%% look allows the player to look around the location
look :- nl, i_am_at(Place),
	describe(Place), nl.





%% notice_objects_at(Place) sets up a loop to mention all the
%  objects in the player's vicinity.
%
notice_objects_at(Place) :-
	thing_at(X, Place),
	write('There is a '), write(X), write('.'), nl,
	alive(X),
	fail.
notice_objects_at(_).





%% use(Object) allows the player to manipulate an object.
%
% Cannot use an item if it isn't in hand
use(W) :-
	listOfItemsInHand(L),
	\+member(W,L),
	write('You do not have that item!'), nl.


% Use the gun against Marlene (must have gun equipped)
use(gun) :-
	i_am_at('salt lake city'),
	thing_at(gun, in_hand),
	thing_at(ammo, in_hand),
	kill('Marlene'),
	write('Marlene: It\'s what she\'d want. And you know it. Look...'), nl,
	write('[She starts lowering her gun.]'), nl,
	write('Marlene: You can still do the right thing here. She won\'t feel anything.'), nl,
	nl, write('[As Marlene lowers her gun, you shoot her. You quickly put Ellie into the nearby pickup truck and drive off.'), nl,

	nl, write('Please proceed to the next location: Tommy\'s settlement.'), nl.


% Use the gun only when you have ammo
use(gun) :-
	write('You do not have any ammo!'), nl,
	\+thing_at(ammo, in_hand).
% Use the gun only against Marlene
use(gun) :-
	write('You cannot use a gun in this case!'), nl,
	\+i_am_at('salt lake city').


% Use the shiv on SPAM enemies
%
% Use the shiv on the 'group of infected SPAM coming your way'
%   in Downtown Boston
use(shiv) :-
	i_am_at(boston),
	thing_at(shiv, in_hand),
	kill('group of infected SPAM coming your way'), nl,
	retract(thing_at(shiv,_)),

	write('A clicker -- a type of infected species of the SPAM fungus that constantly makes clicking noises -- hears you and Ellie talking and rushes toward Ellie who screams (clickers cannot see but attacks based on noise). Before it can harm Ellie, you stab the shiv in the clicker\'s neck and Tess takes care of the rest of the infected SPAM. Your shiv breaks once you use it on the clicker.'), nl,

	write('After defeating your first group of infected SPAM, you, Tess, and Ellie come across a military patrol. The officers whip out scanners and press it to your necks to check if you\'ve been infected by the SPAM.'), nl,

	nl, write('You go first: Negative. Ellie goes next: The scanner starts to beep and flash red... positive?!'), nl,

	nl, write('As soon as Tess hears the beeping, she kills the patrol officers.'), nl,

	nl, write('You: Jesus Christ, Marlene set us up? Why the hell are we smuggling an infected girl?'), nl,
	write('Ellie: I\'m not infected! I can explain!'),nl,

	nl, write('Ellie rolls up her sleeve and reveals a bite mark on it. She tells you and Tess that the bite is over three weeks old. Tess doesn\'t buy it. Everyone turns into SPAM within two days. Does Ellie hold the cure to the SPAM infection?'),nl,

	nl, write('Please proceed to the next location: Pittsburgh.'), nl.

% Use the shiv on the 'herd of infected SPAM' in Pittsburgh
%
use('shiv 2') :-
	i_am_at(pittsburgh),
	thing_at('shiv 2', in_hand),
	kill('herd of infected SPAM'), nl,
	retract(thing_at('shiv 2',_)),

	nl, write('The horde of infected SPAM come running towards you and the rest of the group. Henry and Sam fend off most of them and you all start climbing a ladder to escape.'), nl,

	nl, write('Henry goes up first, then Sam, then Ellie...'), nl,
	write('[The ladder you all have been using breaks when Ellie gets up.'), nl,
	write('Ellie!'), nl,
	write('Henry: Gotcha. [He pulls her up]'), nl,
	write('Ellie: We gotta get Joel up!'), nl,
	write('Henry: Ah...I\'m sorry. We\'re leaving.'),nl,
	write('Sam: What?!'), nl,
	write('Ellie: What? This is bullshit! What the fuck, Henry?'), nl,
	write('[Henry and his brother run away; Ellie jumps back down to Joel.]'), nl,
	write('Ellie: We stick together.'), nl,

	nl, write('At this point, a runner - a type of infected SPAM (unlike clickers, they can see but they run at any enemy they target) - starts heading for you. You hold out your second shiv and the runner runs straight into it.'), nl,

	nl, write('A few more come running towards you and Ellie but you do not have any more shivs. The only way out is to jump into the nearby river.'), nl,

	write('[You and Ellie jump into the river to find that the current is surprisingly strong. The currents rams you into debris and you lose consciousness.]'), nl,

	nl,  write('[You wake up on the beach the next day.]'), nl,

	nl, write('Sam: Henry! He\'s awake!'), nl,
	write('Henry: See? What\'d I tell you, huh? He\'s good. Everything\'s fine. You know, Sam\'s the one who spotted you. You guys had taken quite a bit of water when--'), nl,
	write('[Joel knocks Henry over and tries to strangle Henry.]'), nl,
	write('Ellie: Joel!'), nl,
	write('Joel: He left us to die out there!'), nl,
	write('Henry: No. You had a good chance of making it, and you did. But coming back for you meant putting him at risk. Stay back. If it was the other way around, would you have come back for us?'), nl,

	nl, write('[You think about this for a moment and stops trying to attack Henry]'), nl,
	write('Henry: It''s fine though. I''m okay. Y''know, for what it''s worth, I''m really glad we spotted you. Now, that radio tower is on the other side of this cliff. Okay? Place is gonna be full of supplies. You''re gonna be really happy you didn''t kill me.'), nl,

	nl, write('Please proceed to the next location: Wyoming.'), nl.


% Cannot use a shiv if player is not in Boston or Pittsburgh.
use(shiv) :-
	nl, write('You cannot use a shiv in this case!'), nl,
	\+i_am_at(boston).
use('shiv 2') :-
	nl, write('You cannot use the second shiv in this case!'), nl,
	\+i_am_at(pittsburgh).


% Read the note (which turns out to be a comic book)
use(note) :-
	thing_at(note, in_hand),
	nl, write('Ellie: Okay, we need to lighten the
       mood. Ready? "It doesn\'t matter how much you push the envelope -- it\'ll still be stationary."'), nl,
       write('Joel: What is that?'), nl,
       write('Ellie: A joke book. No Pun Intended: Volume Too by Will Livingston.'), nl,

       nl, write('Joel: Let\'s keep going.'), nl,
       write('Ellie: "What did the Confederate soldiers use to eat off of? Civil ware."'), nl,
       write('Joel: Uh-huh.'), nl,
       write('Ellie: "What did they use to drink with? Cups. Dixie cups." "I walked into my sister\'s room and tripped on a bra. It was a booby-trap." "A book just fell on my head. I only have myself to blame." Oh wait, I said it wrong. Hold on, let me read it again. "A book just fell on my head...I only have my shelf to blame." Heh...ruined it. "What is the leading cause of divorce in long-term marriages? A stalemate."'), nl,

       nl, write('Joel: That\'s awful.'), nl,
       write('Ellie: You\'re awful.'), nl,
       write('Joel: Do you even understand what stalemate means?'), nl,
       write('Ellie: Nope. Doesn\'t matter. Alright, I\'m done...for now.'), nl.


% Use brick to distract enemies
%
use(brick) :-
	i_am_at(wyoming),
	thing_at(brick, in_hand),
	kill('group of bandits in the distance'),
	retract(thing_at(brick,_)),

	nl, write('The bandits come surprisingly close to the settlement. As the bandits pass the last trap that fortifies the settlement, you decide to throw a brick to distract the bandits. With the bandits distracted, alarmed, and panicked, Tommy and the members of his settlement sneak up and fight the bandits off.'), nl,

	nl, write('Joel: That was too damn close.'), nl,
	write('Ellie: Joel! Oh man... They were coming in from every direction--'), nl,
	write('Joel: Okay.'), nl,
	write('Ellie: --then Maria was like "We gotta run!"--'), nl,
	write('Joel: Listen.'), nl,
	write('Ellie: --and so we dove over these tables and this huge guy blasts in with a shotgun--'), nl,
	write('Joel: Slow down, slow down. Listen--'), nl,

	nl, write('Joel tells Ellie that he wants Ellie to stay with his brother, Tommy.'), nl,
	write('Joel: Tommy knows this area better than--'), nl,
	write('Ellie: Agh, fuck that.'), nl,
	write('Joel: Well, I\'m sorry, I trust him better than I trust myself.'), nl,
	write('Ellie: Stop with the bullshit. What are you so afraid of? That I\'m gonna end up like Sam? I can\'t get infected. I can take care of myself.'), nl,
	write('Joel: How many close calls have we had?'), nl,
	write('Ellie: Well, we seem to be doing alright so far.'), nl,
	write('Joel: And now you\'ll be doing even better with Tommy.'), nl,

	nl, write('Ellie: I\'m not her, you know.'), nl,
	write('Joel: What?'), nl,
	write('Ellie: Tommy told me about Sarah. And I--'), nl,
	write('Joel: Ellie. You are treading on some mighty thin ice here.'), nl,
	write('Ellie: I\'m sorry about your daughter, Joel, but I have lost people too. Everyone I have cared for has either died or left me. Everyone except for you. So don\'t tell me that I would be safer with someone else -- because the truth is I\'d just be more scared.'), nl,
	write('Joel: You\'re right... You\'re not my daughter, and I sure as hell ain\'t your dad. And we are going our separate ways.'), nl,

	nl, write('Please proceed to the next location: Colorado.'), nl.


% Can only use the brick in Wyoming
use(brick) :-
	nl, write('You cannot use the brick in this case!'), nl,
	\+i_am_at(wyoming).


% Use the medical kit to heal
use('medical kit') :-
	i_am_at(colorado),
	thing_at('medical kit', in_hand),
	retract(thing_at('medical kit', _)),

	nl, write('You use the medical kit to patch yourself up. However, you are still falling in and out of consciousness.'), nl,

	nl, write('Ellie: I think we\'re safe, Joel. Joel...?'), nl,
	write('Joel: I\'m okay...'), nl,
	write('Ellie: You\'re not okay, Joel! We gotta get you out of here.'), nl,
	nl, write('[You fall down, unconscious.]'), nl,
	write('Ellie: Ah, shit. Joel -- here. Get up, get up, get up...You gotta tell me what to do. Come on... You gotta get up... Joel?'), nl,

	nl, write('Please proceed to the next location: the mountains.'), nl.


% Can only use the medical kit in the mountains
use('medical kit') :-
	nl, write('You cannot use the medical kit in this case!'), nl,
	\+i_am_at(mountains).


% Use the bow and arrow
use('bow and arrow') :-
	i_am_at(mountains),
	thing_at('bow and arrow', in_hand),

	nl, write('Ellie wakes up from the drug that the cannibals have injected into her.'), nl,

	nl, write('David: How are you feeling?'), nl,
	write('[He appears with a dinner tray.]'), nl,
	write('Ellie: Super.'), nl,
	write('David: Here. You should eat. I know you\'re hungry -- been out for quite some time.'), nl,
	write('Ellie: What is it? Deer... with some human helping on the side? You\'re a fucking animal.'), nl,
	write('David: Oh...you\'re awfully quick to judge. Considering you and your friend killed how many men?'), nl,

	nl, write('Ellie: They didn\'t give us a choice...'), nl,
	write('David: And you think we have a choice? Is that it? You kill to survive...and so do we. We have to take care of our own. By any means necessary.'), nl,
	write('Ellie: So now what? You gonna chop me up into tiny pieces?'), nl,
	write('David: I\'d rather not. Please tell me your name.'), nl,
	write('[She shoves the food plate out of her cell.]'), nl,
	write('Ellie: You\'re so full of shit.'), nl,
	write('David: On the contrary, I\'ve been, ah, been quite honest with you. Now I think it\'s your turn. It\'s the only way I\'m gonna be able to convince the others.'), nl,
	write('Ellie: Convince them of what?'), nl,
	write('David: That you can come around. You have heart. You\'re loyal. And you\'re special.'), nl,
	write('[He runs his hands over hers in a very creepy manner.]'), nl,
	write('[She puts her hand on his, then breaks his finger. She tries to grab his cell keys, but he knocks her head into the cell door.]'), nl,
	write('David: You stupid little girl. You are making it very difficult to keep you alive. What am I supposed to tell the others now?'), nl,
       write('Ellie: Ellie.'), nl,
       write('David: What?'), nl,
       write('Ellie: Tell them... that Ellie is the little girl that broke your fucking finger.'), nl,
       write('David: How did you put it? Hmm? Tiny pieces? See you on the slaughter table, Ellie.'), nl,

       nl, write('[Meanwhie, you finally reach consciousness in the resort cabin that you and Ellie were staying at in the mountains.]'), nl,
       write('Joel: Ellie? Ellie?! Where the hell are you?'), nl,
       write('[You go outside to find Ellie when David\'s men - who have been watching the cabin - attack you. You kick one guy and headbutt the other before bringing them down to the basement to start beating them for information. They reveal that Ellie is "David\'s newest pet" and direct you to where she is being kept. Using the weapons they came in with, you kill them after extracting the information and run to Ellie\'s rescue.]'), nl,

       nl, write('[Meanwhile, David and James lift Ellie onto the slaughtering table. Ellie bites David\'s hand -- trying to escape the slaughter.]'), nl,
       write('David: I warned you.'), nl,
       write('[He raises his cleaver.]'), nl,
       write('Ellie: I\'m infected! I\'m infected!...and so are you now that I bit you. Right there. Roll up my sleeve. Look at it!'), nl,
       write('[He sees the wound and grows quiet.]'), nl,
       write('James: What the hell is that?'), nl,
       write('David: She would\'ve turned by now... It can\'t be real.'), nl,
       write('James: Looks pretty fucking real to me!'), nl,
       write('[Ellie quickly takes the cleaver and cuts into James\' neck, rolling off the table towards the doorway. David fires a few rounds but misses. Ellie grabs the bow and arrow from a nearby cabinet before running out of the house and into a restaurant.]'), nl,

       nl, write('[David follows Ellie into the restaurant, which is now on fire. He taunts Ellie as he hunts her down in the restaurant.]'), nl,
       write('David: That\'s alright. There\'s nowhere to go! You want out? You\'re gonna have to come get these keys. I know you\'re not infected. No one who\'s infected fights this hard to stay alive. So what is it, Ellie? I gotta admit, you had me back there. For a second, you shook my faith. But only for a second. You know, I...I wish you hadn\'t killed James. He\'s a good kid -- just doing his job. Ellie! Ellie, come on. I know you\'re dying to say something to me. Come out from where you\'re hiding!'), nl,
       write('Ellie -under her breath-: Creepy piece of shit.'), nl,
       write('David -as he continues to look around for Ellie-: No? Nothin\'? Sure about that? Alright then.'), nl,

       nl, write('[Ellie uses her bow and lands an arrow right in David\'s neck.]'), nl,
       write('At this point, you head over to where David\'s men told you Ellie was but see the burning restaurant. You enter the restaurant and see Ellie grabbing a nearby machete and slashing him, then crawling on him to stab him more.]'), nl,

       nl, write('Ellie! Stop. Stop.'), nl,
       write('Ellie: No! Don\'t fucking touch me!'), nl,
       write('Joel: Shhh. Shhh.'), nl,
       write('Ellie: No--'), nl,
       write('Joel: It\'s okay. It\'s me, it\'s me. Look, look. It\'s me.'), nl,
       write('Ellie: He tried to--'), nl,
       write('Joel -as he embraces her-:- It\'s okay, it\'s okay..'), nl,

	nl, write('Please proceed to the next location: Salt Lake City.'), nl.


% Can only use the bow and arrow in the mountains
use('bow and arrow') :-
	nl, write('You cannot use a bow and arrow in this case!'), nl,
	\+i_am_at(mountains).





%% kill(X) allows the player to attack the enemy
%
% Cannot kill something that isn't there
kill(X) :-
	i_am_at(Place),
	\+thing_at(X, Place),
	write('There\'s nothing there to kill!'), nl.
% Successfully kill the human enemy
kill(X) :-
	i_am_at(Place),
	retract(alive(X)),
	retract(thing_at(X, Place)).
kill(_) :- % For debugging purposes
	write('You must have forgotten a case!'), nl.





%% describe(location) provides a description of that location.
%
describe(boston) :-
	% Location
	write('You, Tess, and Ellie arrive in Downtown Boston.'), nl,

	% Dialog
	nl, write('Ellie: You ever smuggle a kid before?'), nl,
	write('Joel: No. That\'s a first. So what\'s the deal with you and Marlene, anyways?'), nl,
	write('Ellie: I don\'t know. She\'s my friend, I guess.'), nl,
	write('Joel: Your friend, huh? You\'re friends with the leader of the Fireflies. What\'re you, like twelve?'), nl,
	write('Ellie: She knew my mom, and she\'s been looking after me. And I\'m fourteen, not that that has anything to do with anything.'), nl,
	write('Joel: So where are your parents?'), nl,
	write('Ellie: Where are anyone\'s parents? They\'ve been gone a long, long time.'), nl,
	write('Joel: Hm. So instead of just staying in school, you decide to run off and join the Fireflies, is that it?'), nl,
	write('Ellie: Look, I\'m not supposed to tell you why you\'re smuggling me, if that\'s what you\'re getting at.'), nl,
	write('Joel: You wanna know the best thing about my job? I don\'t gotta know why. Be honest with you, I could give two shits about what you\'re up to.'), nl,
	write('Ellie: Well great.'), nl,
	write('Joel: Good.'), nl,

	% Instructions
	nl, write('Before you can drop Ellie off to the Firefly group, you see a group of infected SPAM coming towards you. Defend yourself and most importantly, defend Ellie!'), nl,

	nl, write('You may not proceed to the next location, Pittsburgh, until you defeat the group of infected SPAM!'), nl.


describe(pittsburgh) :-
	% Location
	nl, write('You and Tess continue with your mission from Boston towards Pittsburgh to the Fireflies, who probably want Ellie because they know she\'s immune to the infection. As you continue fighting the infected and avoiding the military, Tess starts to act weird and reveals that she was infected trying to fend off the group of infected SPAM from Boston.'), nl,

	nl, write('[She rolls up Ellie\'s sleeve where Ellie\'s bite mark is.]'),nl,
	write('Tess: This was three weeks. I was bitten an hour ago and it\'s already worse. This is fucking real, Joel. You\'ve got to get this girl to Tommy\'s. He used to run with the Fireflies. He\'ll know where to go.'), nl,

	% Story
	nl, write('A military vehicle pulls up and guards come rushing towards you, Tess, and Ellie -- probably because they know you failed the scan. Tess sacrifices herself to approaching soldiers to give you and Ellie a chance to escape, believing in Ellie\'s importance as a cure. Tess wants you to take Ellie to your brother, Tommy, who used to be part of the FireFlies, who own equipment to extract the cure from Ellie\'s system.'), nl,

	nl, write('Leaving Boston, you and Ellie locate another smuggler who helps you acquire a vehicle. You and Ellie drive from Boston westwards into Pittsburgh, where violent bandits have overthrown the military and hunt down anyone who enters.'), nl,

	nl, write('Your vehicle is then destroyed in an ambush but you later encounter Henry and Sam, brothers attempting to reunite with a group at a radio tower outside the city. As you, Ellie, and your two new "friends" -- although you don\'t really trust them yet -- try to leave Pittsburgh, a horde of Infected attack.'), nl,

	% Instructions
	nl, write('You may not proceed to the next location, Wyoming, until you defeat the herd of infected SPAM!'), nl.


describe(wyoming) :-
	% Location
	nl, write('You and the rest of the group shelter near the tower overnight (which did not really have that many supplies...), where Sam and Ellie have time to bond.'),nl,

	% Dialog
	nl, write('Sam: How is it that you\'re never scared?'), nl,
	write('Ellie: Who says that I\'m not?'), nl,
	write('Sam: What\'re you scared of?'), nl,
	write('Ellie: Let\'s see...scorpions are pretty creepy. Um...being by myself. I\'m scared of ending up alone. What about you?'), nl,
	write('Sam: Those things out there. What if the people are still inside? What if they\'re trapped in there, without any control over their body? I\'m scared of that happening to me.'), nl,
	write('Ellie: Okay, first of all, we\'re a team now. We\'re gonna help each other out. And second, they might still look like people, but that person is not in there anymore. They\'re slowly turning into SPAM.'), nl,
	write('Sam: Henry says that, "they\'ve moved on". That they\'re with their families. Like in heaven. Do you think that\'s true?'), nl,
	write('Ellie: I go back and forth. I mean, I\'d like to believe it.'), nl,
	write('Sam: But you don\'t.'), nl,
	write('Ellie: I guess not... Enough of this serious talk. I\'m going to sleep.'), nl,

	% Story
	nl, write('When Ellie goes to wake Sam up the next morning, he attacks her. Sam, unbeknownst to the rest of the group, was bitten in the attack from Pittsburgh and is now turning into an infected SPAM monster. Henry is forced to kill his infected brother to protect Ellie, and in his grief of killing his own, he commits suicide.'), nl,

	% Instructions
	nl, write('You and Ellie decide to move along. You and Ellie leave Pittsburgh and finally find Tommy in Wyoming, now a member of a fortified settlement near a hydroelectric dam. As you contemplate leaving Ellie with Tommy, a group of bandits approach the settlement.'), nl,

	nl, write('You may not proceed to the next location, Colorado, until you defeat the bandits'), nl.


describe(colorado) :-
	% Location
	nl, write('On second thought, you decide you cannot leave Ellie. She\'s right, Ellie isn\'t your daughter Sarah and you aren\'t responsible for Sarah\'s death. So, you and Ellie leave Wyoming and head to Colorado. Tommy directs you to a Fireflies enclave at the University of Eastern Colorado. You and Ellie arrive only to find the facility abandoned!'), nl,

	% Dialog
	nl, write('Ellie: Hello? Where are they?'), nl,
	write('[They continue searching.]'), nl,
	write('Ellie: Yoohoo! Fireflies?! Cure for mankind over here! Anyone?'), nl,
	write('Joel: Let\'s keep it down until we figure out what\'s going on.'), nl,
	write('[They find some Firefly equipment near a stairwell.]'), nl,
	write('Ellie: Nothing useful.'), nl,
	write('Joel: Ain\'t nothin\' here but a bunch of medical mumbo-jumbo.'), nl,
	write('Ellie: I don\'t get it.'), nl,
	write('Joel: Looks like they all just packed up and left in a hurry.'), nl,

	% Story
	nl, write('A sudden noise occurs upstairs. A group of bandits are scavenging the abandoned facility and they spot you and Ellie. You and Ellie try to escape:'), nl,

	nl, write('Ellie: Who the fuck are these guys?'), nl,
	write('Joel: It doesn\'t matter. We know where to go, let\'s get the hell outta here.'), nl,
	write('Joel opens a balcony door, only to see one of the bandits.'), nl,
	write('Bandit: Got you, asshole.'), nl,
	write('[You and the bandit fall off the balcony. The bandit dies, but You are impaled by some rebar.]'), nl,
	write('Ellie: Oh shit. Oh man...'), nl,
	write('Joel: I\'m fine...I\'m fine.'), nl,
	write('[The bandits inch toward your location. You start blacking out due to blood loss.]'), nl,

	% Instructions
	nl, write('You may not proceed to the next location, Salt Lake City, until you heal.'), nl.


describe(mountains) :-
	% Location
	write('You and Ellie escape the bandits and use the medical kit but you are still in critical condition.'), nl,

	% Story
	nl, write('So, you and Ellie leave Colorado and take shelter in the mountains. You are on the brink of death and must rely on Ellie to take care of you. After hunting a large stag, Ellie encounters David and James, a pair of scavengers willing to trade medicine in exchange for meat. While James goes to recover the medicine, David reveals that the bandits you and Ellie killed at the university were part of his clan. Ellie realizes David is bad news and runs back to you as soon as she trades the meat for the medicine James brings back.'), nl,

	% Dialog
	nl, write('Ellie: Joel? Oh... I only managed to get a little bit of food. But...I did get this. Move your arm. Oh... Here we go.'), nl,
	write('[She gives you the injection, causing you to whie.]'), nl,
	write('Ellie: Sorry. All done. That\'s it. You\'re gonna make it.'), nl,
	write('[She lays beside you and gets some sleep. In the morning, she hears hunters.]'), nl,
	write('Ellie: Oh, fuck. They tracked me. I\'m gonna draw them away from here. I\'ll come back for you.'), nl,
	write('[She leaves the garage, lowering the door quietly.]'), nl,

	nl, write('Eventually, Ellie is captured by David\'s clan and learns that they are all cannibals.'), nl,

	% Instructions
	nl, write('You may not proceed to the last location, Tommy\'s settlement, until you defeat the cannibals!'), nl.


% Player dies if they do not have the gun to kill Marlene
describe('salt lake city') :-
	\+thing_at(gun, in_hand),

	% Location
	write('You and Ellie leave the mountains and find the hospital in Salt Lake City. You must make your way through flooded highway tunnels -- but Ellie cannot swim.'), nl,

	% Dialog
	nl, write('Joel: We don\'t have to do this. You know that, right?'), nl,
	write('Ellie: What\'s the other option?'), nl,
	write('Joel: Go back to Tommy\'s. Just...be done with this whole damn thing.'), nl,
	write('Ellie: After all we\'ve been though. Everything that I\'ve done. It can\'t be for nothing. Look, I know you mean well...but there\'s no halfway with this. Once we\'re done, we\'ll go wherever you want. Okay?'), nl,

	% Story
	nl, write('As you make your way through, you both are caught in rapids. Joel rescues Ellie from drowning, but a patrol of Fireflies capture them. You awaken in the hospital and are greeted by Marlene. She informs you that Ellie is being prepared for surgery: to create a vaccine for the infection, the Fireflies have to remove a SPAM sample from Ellie\'s brain, which will kill her in the process. Joel battles his way to the surgery room and carries an unconscious Ellie to the basement parking garage. There he confronts Marlene.'), nl,

	nl, write('[Marlene points a gun at Joel.]'), nl,
	write('Marlene: You can\'t save her. Even if you get her out of here, then what? How long before she\'s torn to pieces by a pack of SPAM? That is if she hasn\'t been raped and murdered by bandits first.'), nl,
	write('Joel: That ain\'t for you to decide...'), nl,

	% Instructions
	nl, write('Unfortunately, you do not have a gun equipped to defeat Marlene. She shoots you and you are unable to stop the Fireflies from performing surgery on Ellie.'), nl,

	nl, write('Ellie dies during the surgery and, to everyone\'s dismay, the cure still isn\'t found.'), nl,

	nl, end.


describe('salt lake city') :-
	% Location
	write('You and Ellie leave the mountains and find the hospital in Salt Lake City. You must make your way through flooded highway tunnels -- but Ellie cannot swim.'), nl,

	% Dialog
	nl, write('Joel: We don\'t have to do this. You know that, right?'), nl,
	write('Ellie: What\'s the other option?'), nl,
	write('Joel: Go back to Tommy\'s. Just...be done with this whole damn thing.'), nl,
	write('Ellie: After all we\'ve been though. Everything that I\'ve done. It can\'t be for nothing. Look, I know you mean well...but there\'s no halfway with this. Once we\'re done, we\'ll go wherever you want. Okay?'), nl,

	% Story
	nl, write('As you make your way through, you both are caught in rapids. Joel rescues Ellie from drowning, but a patrol of Fireflies capture them. You awaken in the hospital and are greeted by Marlene. She informs you that Ellie is being prepared for surgery: to create a vaccine for the infection, the Fireflies have to remove a SPAM sample from Ellie\'s brain, which will kill her in the process. Joel battles his way to the surgery room and carries an unconscious Ellie to the basement parking garage. There he confronts Marlene.'), nl,

	nl, write('[Marlene points a gun at Joel.]'), nl,
	write('Marlene: You can\'t save her. Even if you get her out of here, then what? How long before she\'s torn to pieces by a pack of SPAM? That is if she hasn\'t been raped and murdered by bandits first.'), nl,
	write('Joel: That ain\'t for you to decide...'), nl,

	% Instructions
	nl, write('You may not proceed to the next location, Tommy\'s settlement, until you defeat Marlene!'), nl.


describe('Tommy\'s settlement') :-
	% Location
	write('You and Ellie leave the hospital in Salt Lake City to go back to Tommy\'s settlement.'), nl,

	% Dialog
	nl, write('[Joel is driving out of town as Ellie wakes up.]'), nl,
	write('Ellie: What the hell am I wearing?'), nl,
	write('Joel: Just take it easy...drugs are still wearing off.'), nl,
	write('Ellie: What happened?'), nl,
	write('Joel: We found the Fireflies. Turns out there\'s a whole lot more like you, Ellie. People that are immune. It\'s dozens actually. Ain\'t done a damn bit of good either. They\'ve actually st-- They\'ve stopped looking for a cure. I\'m taking us home. I\'m sorry.'), nl,
	nl, write('Joel lies to her about the events and Ellie expresses her survivor guilt.'), nl,

	nl, write('Ellie: Hey, wait. Back in Boston -- back when I was bitten -- I wasn\'t alone. My best friend was there. And she got bit too. We didn\'t know what to do. So...she says "Let\'s just wait it out. Y\'know, we can be all poetic and just lose our minds together." I\'m still waiting for my turn.'), nl,
	write('Joel: Ellie--'), nl,
	write('Ellie: Her name was Riley and she was the first to die. And then it was Tess. And then Sam.'), nl,
	write('Joel: None of that is on you.'), nl,
	write('Ellie: No, you don\'t understand.'), nl,
	write('Joel: I struggled for a long time with survivin\'. And you-- No matter what, you keep finding something to fight for. Now, I know that\'s not what you want to hear right now, but it\'s--'), nl,
	write('Ellie: Swear to me. Swear to me that everything you said about the Fireflies is true.'), nl,
	write('[There\'s a short pause.]'), nl,
	write('Joel: I swear.'), nl,
	write('[A long pause.]'), nl,
	write('Ellie: Okay.'), nl,

	% End description
	write('You have reached the end of the game successfully. Thank you for playing "The Last of Us: Survive the SPAM" and always remember: endure and survive.'), nl,

	nl, end.










%% "end" requests the user to perform the final command
%     to end the game
end :-
	nl,
	write('The game is over'), nl,
        write('Please enter the "halt." command.'), nl.





%% The predicates used to start the game
start :- instructions, look, notice_objects_at(boston).

instructions :-
    nl,
    write('The Last Of Us: Survive the SPAM'), nl,

    nl,
    write('Joel is a single father living outside Austin, Texas with his twelve-year old daughter Sarah. In the early hours on the day after his birthday, a sudden outbreak of a mutated Special Processed American Meat fungus - also known as SPAM - begings ravaging the United States, which changes its human hosts into violent monsters. As Joel, Sarah, and Joel\'s brother Tommy flee the chaos, Sarah is shot by a soldier and dies in Joel\'s arms.'), nl,

    nl,
    write('In the twenty years that follow, much of civilization is destroyed by the infection, with isolated pockets of survivors living in heavily policed quarantine zones, independent settlements, or nomadic groups. Joel now lives in a quarantine zone in Boston, working as a smuggler alongside his partner, Tess. They hunt down a local gangster to recover weapons stolen from them. Before Tess kills him, the gangster reveals that he traded the weapons to the Fireflies, an insurgent militia fighting against the authorities governing the quarantine zones.'), nl,

    nl, write('The Fireflies are an anti-government militia group that calls for the return of all branches of government in the wake of military oppression. They are fighting a losing war against the military whom they view as tyrants. The Fireflies are one of the few organized groups still searching for a vaccine for the SPAM infection and will do whatever it takes to accomplish it. The militia group is spread throughout the country, but their main base is located at St. Mary\'s Hospital in Salt Lake City, Utah.'), nl,

    nl, write('Joel and Tess encounter the Fireflies\' leader, Marlene, who promises them double their stolen cache in return for smuggling a teenage girl named Ellie outside the quarantine to a Firefly group in downtown Boston.'), nl,

    nl, write('OBJECTIVE:'), nl,
    write('Your job is to take control of Joel, who is trekking across a post-apocalyptic United States in 2033, in order to escort the young Ellie to a resistance group, the Fireflies. You must defend yourself and Ellie against zombie-like creatures infected by a mutated strain of the SPAM fungus, as well as hostile humans such as bandits and cannibals. When you reach the last location, your mission is complete.'), nl,

    nl,
    write('HOW TO CONTROL:'), nl,
    write('Enter commands using standard Prolog syntax.'), nl,
    write('Available commands are:'), nl,
    write('start. -- to start the game.'), nl,
    write('proceed OR return -- to go in that direction.'), nl,
    write('take(Object). -- to pick up an object.'), nl,
    write('drop(Object). -- to put down an object.'), nl,
    write('use(Object). -- to manipulate an object.'), nl,
    write('inventory. -- to see what objects are in your possession.'), nl,
    write('look. -- to look around you.'), nl,
    write('instructions. -- to see this message again.'), nl,
    write('halt. -- to end the game and quit.'), nl,
    write('restart. -- to start a new game without closing window.'), nl,
    nl.





% "restart" allows the player to start with a brand new game
%  without having to re-open Prolog
restart :-
	retractall(thing_at(_, _)),
	retractall(i_am_at(_)),
	retractall(alive(_)),

	assert(thing_at(gun, boston)),
	assert(thing_at(shiv, boston)),
	assert(thing_at(note, pittsburgh)),
	assert(thing_at(brick, wyoming)),
	assert(thing_at('medical kit', colorado)),
	assert(thing_at('bow and arrow', mountains)),
	assert(thing_at(ammo, 'salt lake city')),
	assert(thing_at('group of infected SPAM coming your way', boston)),
	assert(thing_at('herd of infected SPAM', pittsburgh)),
	assert(thing_at('group of bandits in the distance', wyoming)),
	assert(thing_at('scary-looking group of bandits', colorado)),
	assert(thing_at(cannibal, mountains)),
	assert(thing_at('Marlene', endlocation)),
	assert(i_am_at(_)),
	assert(alive(_)),

	start.
