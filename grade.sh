CPATH='.:lib/hamcrest-core-1.3.jar:lib/junit-4.13.2.jar'

rm -rf student-submission
rm -rf grading-area

mkdir grading-area

git clone $1 student-submission
echo 'Finished cloning'


# Draw a picture/take notes on the directory structure that's set up after
# getting to this point

# Then, add here code to compile and run, and do any post-processing of the
# tests

submission=$(find "student-submission" -type f -name "*.java")
file_name=$(basename $submission .java)

if [ -n "$file_name" ];
then
    echo "file found"
    echo $file_name
else
    echo "File not found"
    echo "Grade: 0%"
    
fi

cp $submission TestListExamples.java grading-area
cp -r lib grading-area

cd grading-area

ls TestListExamples.java

if [ $file_name = "ListExamples" ];
then :
else
    cp TestListExamples.java TestListExamples.txt

    sed -i '' -e s/ListExamples/$file_name/g TestListExamples.txt

    mv TestListExamples.txt Test$file_name.java

    rm TestListExamples.java
fi

javac -cp $CPATH *.java

if [[ $? -eq 0 ]];
then
    echo "compilation successful"
else
    echo "compilation not successful"
    echo "Grade: 0%"
    
    exit
fi

java -cp $CPATH org.junit.runner.JUnitCore Test$file_name > test_output.txt

if grep -q "OK" test_output.txt;
then
    echo "Grade: 100%"
else
    tests_run=$(grep -o "Tests run: [0-9]*" test_output.txt | cut -d' ' -f3)
    failures=$(grep -o "Failures: [0-9]*" test_output.txt | cut -d' ' -f2)

    successful_tests=$((tests_run - failures))
    percentage=$(echo "scale=2; ($successful_tests / $tests_run) * 100" | bc)

    echo "Grade: $percentage%"
fi
