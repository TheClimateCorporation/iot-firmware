# USAGE
# python motion_detector.py
# python motion_detector.py --video videos/example_01.mp4

# import the necessary packages
import argparse
import datetime
import imutils
import sys
import pprint
import time
import cv2
import logging

THRESHOLD_ADJUST = 55

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler(sys.stdout)
ch.setLevel(logging.DEBUG)
logging_formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
ch.setFormatter(logging_formatter)
logger.addHandler(ch)

# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-v", "--video", help="path to the video file")
ap.add_argument("-a", "--min-area", type=int, default=500, help="minimum area size")
args = vars(ap.parse_args())

CV_CAP_PROP_FRAME_WIDTH = 3
CV_CAP_PROP_FRAME_HEIGHT = 4
CV_CAP_PROP_FPS = 5

# if the video argument is None, then we are reading from webcam
if args.get("video", None) is None:
        logger.info("trying to capture from the camera")
        camera = cv2.VideoCapture(0)
        camera.set(CV_CAP_PROP_FRAME_WIDTH, 320)
        camera.set(CV_CAP_PROP_FRAME_HEIGHT, 240)
        camera.set(CV_CAP_PROP_FPS, 3)
        #time.sleep(5.0)
        logger.info("finished camera setup")

# otherwise, we are reading from a video file
else:
    camera = cv2.VideoCapture(args["video"])

# initialize the first frame in the video stream
firstFrame = None

baseContours = None
baseThreshold = THRESHOLD_ADJUST
thresholdAdjusted = False

# loop over the frames of the video
while True:
        # grab the current frame and initialize the occupied/unoccupied
        # text
        grabbed, frame = camera.read()
        frame = cv2.flip(frame, flipCode = 0)
        text = "Unoccupied"

        # if the frame could not be grabbed, then we have reached the end
        # of the video
        if not grabbed:
                logger.info("we didn't grab any frames!")
                break

        # resize the frame, convert it to grayscale, and blur it
        #frame = imutils.resize(frame, width=500)
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        gray = cv2.GaussianBlur(gray, (21, 21), 0)

        # if the first frame is None, initialize it
        if firstFrame is None:
                firstFrame = gray
                continue

        # compute the absolute difference between the current frame and
        # first frame
        frameDelta = cv2.absdiff(firstFrame, gray)
        thresh = cv2.threshold(frameDelta, baseThreshold, 255, cv2.THRESH_BINARY)[1]
        # thresh = cv2.adaptiveThreshold(frameDelta,255,cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY,11,5)

        # dilate the thresholded image to fill in holes, then find contours
        # on thresholded image
        thresh = cv2.dilate(thresh, None, iterations=2)
        (cnts, _) = cv2.findContours(thresh.copy(), cv2.RETR_EXTERNAL,
                cv2.CHAIN_APPROX_SIMPLE)
        logger.info("Found %d contours" % len(cnts))
        if not thresholdAdjusted:
                if len(cnts) > 0:
                        logger.info("Calibrating... baseThreshold was {}".format(baseThreshold))
                        baseThreshold = baseThreshold + 1
                elif len(cnts) == 0:
                        logger.info("Threshold calibration complete!")
                        thresholdAdjusted = True
                        firstFrame = gray # update firstFrame to the current image
        # loop over the contours
        for c in cnts:
                # if the contour is too small, ignore it
                if cv2.contourArea(c) < args["min_area"]:
                        continue

                # compute the bounding box for the contour, draw it on the frame,
                # and update the text
                (x, y, w, h) = cv2.boundingRect(c)
                cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)

                if baseContours == None:
                        baseContours = len(cnts)
                text = "Occupied"

        # draw the text and timestamp on the frame
        cv2.putText(frame, "Room {}, {}/{}".format(text, len(cnts), baseContours), (10, 20),
                cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2)
        cv2.putText(frame, datetime.datetime.now().strftime("%A %d %B %Y %I:%M:%S%p"),
                (10, frame.shape[0] - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.35, (0, 0, 255), 1)

        # show the frame and record if the user presses a key
        cv2.imshow("Security Feed", frame)
        cv2.imshow("Thresh", thresh)
        cv2.imshow("Frame Delta", frameDelta)
        key = cv2.waitKey(1) & 0xFF

        # if the `q` key is pressed, break from the lop
        if key == ord("q"):
                break

# cleanup the camera and close any open windows
camera.release()
cv2.destroyAllWindows()
