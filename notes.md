# Presenter Notes

### Setup

```
brew install sdl2                 # OSX
sudo apt-get install libsdl2-dev  # Linux
bundle
```

### Context

- Imagine 7 Scrabble pieces are put in front of you.
- "What are all the English words I can make?"

### Check for prior knowledge

- Ever added an index to a database field? Hands up if you feel like you know
  how it works. Can you explain it to us?

### Questions for discussion

- Imagine finding all the words you can make with 7 Scrabble tiles just with a
  paper dictionary, no computer.
- What steps would you take?
- When looking at a word in the dictionary and comparing it to your Scrabble
  letter tiles, what goes through your mind?
- If your tiles do not have a B, what do you do when you get to the B chapter
  of the dictionary?
- When do you know for sure that you can stop considering a word and move
  onto the next one?
- How many little decisions would you have to make in your head?

----------------------------------------------------------------------

### Bigwords 0

#### Demo

Let's see a computer do it:

```
bundle exec ruby bigwords_0.rb
```

#### Discussion

- Each time you look at a set of tiles and a word from the dictionary, how
  many if statements do you need?

  For 7 Scrabble letters and an average 5 letter word, 35 if statements.

  You can write it as `DT` where

  - D is the number of letters in the dictionary word
  - T is the number of Scrabble tiles

  T goes down 1 for each D since we will remove them as we check them off.
  This is a linear reduction each time, so the performance is `O(DT)` or,
  assuming both are similar numbers, `O(N^2)`

- What does `O(N^2)` mean?

- How many words are there in the dictionary? How many if statements do we
  need in total then?

  This dictionary has about 70k words in it. The So about 70k * 35 = 2,450k

  As an equation we could write it as `WDT` where W is the number of words
  in the dictionary.

  This is a measurement of the amount of work we have to do.

#### Look at the code if anybody wants to

----------------------------------------------------------------------

### Bigwords 1

#### Discussion

- Could you arrange the dictionary better before you started, to reduce
  the amount of work? Any ideas?

- Could we arrange the dictionary into lists of words that *do* have a given
  letter? Would that help us find the words we care about?

- Could we arrange the dictionary into lists of words that *do not* have
  a given letter? Would that help us find the words we care about?

- Could we arrange each list of words into further sub-lists? What shape
  would that data structure have? Could you draw it?

#### Demo

Let's see the same program but using a binary search tree:

```
bundle exec ruby bigwords_1.rb
```

----------------------------------------------------------------------

### Bigwords 2

#### Demo

Can we visualise what is going on?

```
bundle exec ruby bigwords_2.rb
```

Pause the program using the space bar each time it changes and explain what is
happening.

  - What decision does the program need to make at this point?
  - What words can the program safely ignore at this point?

#### Discussion

- If you were evil, could you arrange the tree to maximise the amount of work
  the program has to do? How would you arrange it?

- Could you arrange the tree to minimise the amount of work? How?

- Could you "fix" a bad tree?

- Recall our original `WDT` and `O(N^2)` equations? How do these change when we
  use a binary search tree? What happens to the W term? How many lists is it
  divided into? How much work is it to find the right lists of words? Worst case?
  Best case?
