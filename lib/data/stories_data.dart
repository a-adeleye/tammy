import '../models/story.dart';
import '../models/story_scene.dart';

const List<Story> storiesData = [
  Story(
    id: 's1',
    title: 'The Red Ball',
    scenes: [
      StoryScene(
        id: 's1_1',
        text: 'Ali has a red ball.',
        practiceLine: 'Red ball.',
      ),
      StoryScene(
        id: 's1_2',
        text: 'Ali throws the red ball.',
        practiceLine: 'Throw the ball.',
      ),
      StoryScene(
        id: 's1_3',
        text: 'The ball rolls under the chair.',
        practiceLine: 'Where is the ball?',
      ),
      StoryScene(
        id: 's1_4',
        text: 'Mama helps Ali get the ball.',
        practiceLine: 'Help me, please.',
      ),
    ],
    finalQuestion: 'Where is the ball?',
    answerOptions: ['Under the chair', 'On the table', 'In the box'],
    correctAnswerIndex: 0,
  ),
  Story(
    id: 's2',
    title: 'Banana Snack',
    scenes: [
      StoryScene(
        id: 's2_1',
        text: 'Sara is hungry.',
        practiceLine: 'I am hungry.',
      ),
      StoryScene(
        id: 's2_2',
        text: 'She sees yellow bananas.',
        practiceLine: 'Yellow bananas.',
      ),
      StoryScene(
        id: 's2_3',
        text: 'Sara says, "I want to eat bananas."',
        practiceLine: 'I want to eat.',
      ),
      StoryScene(
        id: 's2_4',
        text: 'She eats the bananas. She is happy.',
        practiceLine: 'I am happy.',
      ),
    ],
    finalQuestion: 'What did Sara eat?',
    answerOptions: ['Apple', 'Bananas', 'Soup'],
    correctAnswerIndex: 1,
  ),
];
