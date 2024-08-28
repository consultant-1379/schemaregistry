/*------------------------------------------------------------------------------
 *******************************************************************************
 * COPYRIGHT Ericsson 2021
 *
 * The copyright to the computer program(s) herein is the property of
 * Ericsson Inc. The programs may be used and/or copied only with written
 * permission from Ericsson Inc. or in accordance with the terms and
 * conditions stipulated in the agreement/contract under which the
 * program(s) have been supplied.
 *******************************************************************************
 *----------------------------------------------------------------------------*/

package com.ericsson.adp.mgmt.sr.bragent.agent;

/**
 * FileException class.
 */
public class FileException extends RuntimeException {

    /**
     * Throws exception message.
     *
     * @param message
     *         - message to be passed
     */
    public FileException(final String message) {
        super(message);
    }

    /**
     * Throws exception object.
     *
     * @param throwable
     *         - throwable object
     */
    public FileException(final Throwable throwable) {
        super(throwable);
    }
}
