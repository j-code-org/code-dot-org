import React from 'react';
import SeeMoreCourses from './SeeMoreCourses';

const courses = [
  {
    name: "Play Lab",
    description: "Create a story or make a game with Play Lab!",
    link: "https://code.org/playlab",
  },
  {
    name: "CSP Unit 2 - Digital Information",
    description: "Explore how more complex digital information is represented and manipulated through computation and visualization",
    link: "https://curriculum.code.org/csp/unit2/",
  },
  {
    name: "CSP Unit 2 - Digital Information",
    description: "Explore how more complex digital information is represented and manipulated through computation and visualization",
    link: "https://curriculum.code.org/csp/unit2/",
  },
];

export default storybook => {
  return storybook
    .storiesOf('SeeMoreCourses', module)
    .addStoryTable([
      {
        name: 'See More Courses for homepages',
        description: `If a teacher has progress in more than 4 courses or a student in more than 5, they will see a "View More" button. When they click button, they will see the remainder of their courses.`,
        story: () => (
          <SeeMoreCourses
            courses={courses}
            isRtl={false}
          />
        )
      },
    ]);
};
